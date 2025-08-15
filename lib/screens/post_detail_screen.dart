import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../providers/comments_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/comment_tile.dart';
import '../widgets/add_comment_widget.dart';
import 'user_profile_screen.dart';

/// Screen to display full details of a Post,
/// including title, author info, body, comment list, and a form to add comments.
class PostDetailScreen extends ConsumerWidget {
  static const routeName = '/post-detail';

  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retrieve post passed as navigation argument
    final post = ModalRoute.of(context)!.settings.arguments as Post;

    // Watch providers for author user list and comments for this post
    final usersAsync = ref.watch(usersProvider);
    final commentsAsync = ref.watch(commentsProvider(post.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'View Author Profile',
            onPressed: () {
              // Navigate to user profile on author icon tap
              usersAsync.whenData((users) {
                final user = users.firstWhere(
                  (u) => u.id == post.userId,
                  orElse: () => User(
                    id: 0,
                    name: 'Unknown',
                    username: 'unknown',
                    avatarUrl: '',
                  ),
                );
                Navigator.pushNamed(
                  context,
                  UserProfileScreen.routeName,
                  arguments: user,
                );
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post title with headline styling
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Author info with avatar and name, tappable to navigate to profile
            usersAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Error loading user: $error'),
              data: (users) {
                final user = users.firstWhere(
                  (u) => u.id == post.userId,
                  orElse: () => User(
                    id: 0,
                    name: 'Unknown',
                    username: 'unknown',
                    avatarUrl: '',
                  ),
                );
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      UserProfileScreen.routeName,
                      arguments: user,
                    );
                  },
                  child: Row(
                    children: [
                      // Hero animation on avatar between list and detail screen
                      Hero(
                        tag: 'avatar_${post.userId}',
                        child: CircleAvatar(
                          backgroundImage: user.avatarUrl.isNotEmpty
                              ? NetworkImage(user.avatarUrl)
                              : null,
                          child: user.avatarUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Expanded scrollable area for the post body text
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  post.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),

            const Divider(height: 32),

            // Comments section header with count
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Expanded comment list below, with loading/error states
            Expanded(
              child: commentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Error loading comments: $error'),
                data: (comments) => comments.isEmpty
                    ? const Text('No comments yet.')
                    : ListView.separated(
                        itemCount: comments.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          return CommentTile(comment: comments[index]);
                        },
                      ),
              ),
            ),

            // Input widget to add a new comment
            AddCommentWidget(postId: post.id),
          ],
        ),
      ),
    );
  }
}
