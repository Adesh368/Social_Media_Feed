import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';

/// Screen that shows user profile info including avatar, name, username,
/// and their posts displayed in a list below.
class UserProfileScreen extends ConsumerWidget {
  static const routeName = '/user-profile';

  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // User passed as argument when navigating to this screen
    final user = ModalRoute.of(context)!.settings.arguments as User;

    // Watch posts provider asynchronously
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.name}\'s Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero wrapped avatar for smooth transition from post card
            Hero(
              tag: 'avatar_${user.id}',
              child: CircleAvatar(
                radius: 48,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child:
                    user.avatarUrl.isEmpty ? const Icon(Icons.person, size: 48) : null,
              ),
            ),

            const SizedBox(height: 12),

            // Display user's full name
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            // User's username in subtitle style
            Text(
              '@${user.username}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const Divider(height: 32),

            // Expanded list of posts authored by this user
            Expanded(
              child: postsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error loading posts: $error')),
                data: (posts) {
                  // Filter posts where userId matches current user
                  final userPosts =
                      posts.where((post) => post.userId == user.id).toList();

                  if (userPosts.isEmpty) {
                    return const Center(child: Text('No posts by this user yet.'));
                  }

                  // List of PostCard widgets for each user post
                  return ListView.builder(
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) =>
                        PostCard(post: userPosts[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
