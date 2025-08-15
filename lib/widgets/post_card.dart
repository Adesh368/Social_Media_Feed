import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../providers/users_provider.dart';
import '../screens/post_detail_screen.dart';

/// Widget representing a single post card in a list.
/// Displays post title, author avatar and name, and navigates on tap.
class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wrap avatar with Hero widget for animation on navigation
    return Hero(
      tag: 'avatar_${post.userId}',
      child: Material(
        type: MaterialType.transparency,
        child: Consumer(
          builder: (context, ref, _) {
            final usersAsync = ref.watch(usersProvider);

            // Handle user data loading/error states
            return usersAsync.when(
              loading: () => ListTile(
                leading: const CircleAvatar(child: CircularProgressIndicator()),
                title: Text(post.title),
              ),
              error: (error, _) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.error)),
                title: Text(post.title),
                subtitle: const Text('Error loading user'),
              ),
              data: (users) {
                // Lookup user who authored the post
                final user = users.firstWhere(
                  (u) => u.id == post.userId,
                  orElse: () => User(
                    id: 0,
                    name: 'Unknown',
                    username: 'unknown',
                    avatarUrl: '',
                  ),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.avatarUrl.isNotEmpty
                          ? NetworkImage(user.avatarUrl)
                          : null,
                      child: user.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text(post.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('by ${user.name}',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      // Navigate to post detail passing the post object
                      Navigator.pushNamed(
                        context,
                        PostDetailScreen.routeName,
                        arguments: post,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
