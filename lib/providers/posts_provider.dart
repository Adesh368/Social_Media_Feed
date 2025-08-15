import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/cache_helper.dart';

class PostsAsyncNotifier extends AsyncNotifier<List<Post>> {
  static const _cacheKey = 'cached_posts';
  // Key used to store posts in SharedPreferences.

  List<Post>? _cachedPosts;
  // Holds the latest list of posts in memory.

  DateTime? _lastFetch;
  // Stores the last time posts were fetched.

  Timer? _webSocketSimulator;
  // Timer to simulate real-time WebSocket updates.

  @override
  Future<List<Post>> build() async {
    // Ensure cleanup when provider is disposed
    ref.onDispose(() {
      _webSocketSimulator?.cancel();
      // Cancel the WebSocket simulator timer.
      _webSocketSimulator = null;
      // Clear the reference to free memory.
    });

    // Try to load from cache first
    final cachedJson = await CacheHelper.getData(_cacheKey);
    // Read cached posts JSON from SharedPreferences.

    if (cachedJson != null) {
      try {
        final cachedList =
            (cachedJson as List).map((e) => Post.fromJson(e)).toList();
        // Convert the cached JSON list into Post objects.

        _cachedPosts = cachedList;
        _lastFetch = DateTime.now();
        // Mark as freshly loaded.

        _startWebSocketSimulator();
        // Begin simulating real-time updates.

        return cachedList;
        // Return cached posts immediately.
      } catch (_) {
        // If cache is corrupted, ignore and fetch fresh data.
      }
    }

    // If no valid cache, fetch from API and store in cache
    final result = await _fetchAndCachePosts();

    _startWebSocketSimulator();
    // Start simulated updates.

    return result;
    // Return fetched posts.
  }

  // Helper to fetch posts from API and save to cache
  Future<List<Post>> _fetchAndCachePosts() async {
    try {
      final posts = await ApiService.fetchPosts();
      // Call the API to get fresh posts.

      _cachedPosts = posts;
      _lastFetch = DateTime.now();
      // Update in-memory data.

      final postsJsonList = posts.map((e) => e.toJson()).toList();
      // Convert posts to JSON for storage.

      await CacheHelper.saveData(_cacheKey, postsJsonList);
      // Save to persistent cache.

      return posts;
      // Return posts to caller.
    } catch (e) {
      rethrow;
      // Pass the error up to the caller.
    }
  }

  // Refresh posts manually, forcing reload
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    // Show loading state to UI.

    try {
      final posts = await ApiService.fetchPosts();
      // Get fresh posts from API.

      _cachedPosts = posts;
      _lastFetch = DateTime.now();

      await CacheHelper.saveData(
        _cacheKey,
        posts.map((e) => e.toJson()).toList(),
      );
      // Save new posts to cache.

      state = AsyncValue.data(posts);
      // Update state with new posts.
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Show error state to UI.
    }
  }

  // Add a new post with optimistic UI update
  Future<void> addPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    final currentPosts = state.value ?? [];
    // Get current posts or empty list.

    final tempId = DateTime.now().millisecondsSinceEpoch;
    // Temporary unique ID for optimistic post.

    final newPost = Post(id: tempId, userId: userId, title: title, body: body);
    // Create a new Post object.

    final optimistic = [newPost, ...currentPosts];
    // New post at the top.

    state = AsyncValue.data(optimistic);
    // Show it in the UI immediately.

    _cachedPosts = optimistic;
    // Update memory cache.

    await CacheHelper.saveData(
      _cacheKey,
      optimistic.map((e) => e.toJson()).toList(),
    );
    // Save to persistent cache.

    try {
      final created = await ApiService.createPost(title, body, userId);
      // Call API to create the post.

      final updated = _cachedPosts!.map((p) {
        return p.id == tempId ? created : p;
        // Replace temporary post with API post.
      }).toList();

      _cachedPosts = updated;
      state = AsyncValue.data(updated);

      await CacheHelper.saveData(
        _cacheKey,
        updated.map((e) => e.toJson()).toList(),
      );
      // Save updated list to cache.
    } catch (e) {
      _cachedPosts = currentPosts;
      state = AsyncValue.data(currentPosts);
      // Revert to old list on error.

      await CacheHelper.saveData(
        _cacheKey,
        currentPosts.map((e) => e.toJson()).toList(),
      );
      // Save reverted state to cache.

      rethrow;
      // Forward error to caller.
    }
  }

  // Simulates receiving live posts every 30 seconds
  void _startWebSocketSimulator() {
    _webSocketSimulator?.cancel();
    // Stop existing timer if running.

    _webSocketSimulator =
        Timer.periodic(const Duration(seconds: 30), (_) async {
      // Every 30 seconds, simulate a new post.

      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: 99,
        title: 'Live update at ${DateTime.now()}',
        body: 'This is a simulated live post via WebSocket',
      );

      final current = _cachedPosts ?? [];
      final updated = [newPost, ...current];
      // Add the simulated post to the top.

      _cachedPosts = updated;
      state = AsyncValue.data(updated);
      // Update UI with new list.

      await CacheHelper.saveData(
        _cacheKey,
        updated.map((e) => e.toJson()).toList(),
      );
      // Save updated list to cache.
    });
  }
}

// Riverpod provider to expose PostsAsyncNotifier state
final postsProvider = AsyncNotifierProvider<PostsAsyncNotifier, List<Post>>(
    PostsAsyncNotifier.new);
