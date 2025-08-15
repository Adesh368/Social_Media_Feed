import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../utils/cache_helper.dart';

/// AsyncNotifier for managing comments for a specific post.
/// Uses AutoDispose + Family so each postId gets its own instance.
class CommentsAsyncNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Comment>, int> {
  List<Comment>? _cachedComments;
  DateTime? _lastFetch;

  /// Cache key based on postId
  String _cacheKey(int postId) => 'cached_comments_post_$postId';

  /// The build method is called automatically when the provider is first accessed.
  /// `postId` is passed from the family argument.
  @override
  Future<List<Comment>> build(int postId) async {
    // Try to load from cache first
    final cachedJson = await CacheHelper.getData(_cacheKey(postId));
    if (cachedJson != null) {
      try {
        final cachedList =
            (cachedJson as List).map((e) => Comment.fromJson(e)).toList();
        _cachedComments = cachedList;
        _lastFetch = DateTime.now();
        return cachedList;
      } catch (_) {
        // If cache is corrupted, ignore and fetch fresh
      }
    }

    // Fetch from API and cache
    return await _fetchAndCacheComments(postId);
  }

  /// Fetch comments from API and save to cache
  Future<List<Comment>> _fetchAndCacheComments(int postId) async {
    try {
      final comments = await ApiService.fetchComments(postId);
      _cachedComments = comments;
      _lastFetch = DateTime.now();

      await CacheHelper.saveData(
        _cacheKey(postId),
        comments.map((e) => e.toJson()).toList(),
      );

      return comments;
    } catch (e) {
      rethrow;
    }
  }

  /// Force-refresh comments from API
  Future<void> refresh(int postId) async {
    state = const AsyncValue.loading();
    try {
      final comments = await ApiService.fetchComments(postId);
      _cachedComments = comments;
      _lastFetch = DateTime.now();

      await CacheHelper.saveData(
        _cacheKey(postId),
        comments.map((e) => e.toJson()).toList(),
      );

      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Optimistically add a comment
  Future<void> addComment({
  required String body,
  required String authorName,
}) async {
  final postId = this.arg; // family argument passed into build()

  final currentComments = state.value ?? [];

  final tempId = DateTime.now().millisecondsSinceEpoch;
  final newComment = Comment(
    id: tempId,
    postId: postId,
    body: body,
    authorName: authorName,
  );

  // Optimistic update
  state = AsyncValue.data([newComment, ...currentComments]);
  _cachedComments = [newComment, ...currentComments];

  await CacheHelper.saveData(
    _cacheKey(postId),
    _cachedComments!.map((e) => e.toJson()).toList(),
  );

  try {
    final createdComment =
        await ApiService.createComment(postId, body, authorName);

    final updatedComments = _cachedComments!.map((comment) {
      return comment.id == tempId ? createdComment : comment;
    }).toList();

    _cachedComments = updatedComments;
    state = AsyncValue.data(updatedComments);

    await CacheHelper.saveData(
      _cacheKey(postId),
      updatedComments.map((e) => e.toJson()).toList(),
    );
  } catch (e) {
    // Revert on failure
    state = AsyncValue.data(currentComments);
    _cachedComments = currentComments;

    await CacheHelper.saveData(
      _cacheKey(postId),
      currentComments.map((e) => e.toJson()).toList(),
    );

    rethrow;
  }
}

}

/// Provider for comments, scoped by postId
final commentsProvider = AutoDisposeAsyncNotifierProvider.family<
    CommentsAsyncNotifier, List<Comment>, int>(
  CommentsAsyncNotifier.new,
);
