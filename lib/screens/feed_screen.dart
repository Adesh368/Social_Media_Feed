import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_dialog.dart';

/// The main feed screen showing a searchable list of posts with a floating button
/// to create new posts. Supports pull-to-refresh and realtime updates via provider.
class FeedScreen extends ConsumerStatefulWidget {
  static const routeName = '/';

  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  String searchQuery = ''; // Current search query string from input field

  @override
  Widget build(BuildContext context) {
    // Watch the posts provider, which is AsyncValue<List<Post>>
    final postsAsyncValue = ref.watch(postsProvider);

    // This list holds the filtered posts based on searchQuery
    List<Post> filteredPosts = [];

    // When posts data is available, apply local filtering of the post list
    postsAsyncValue.whenData((posts) {
      filteredPosts = searchQuery.isEmpty
          ? posts // No search: show all posts
          : posts.where((post) {
              final query = searchQuery.toLowerCase();
              // Filter posts where title or body contains the search query (case-insensitive)
              return post.title.toLowerCase().contains(query) ||
                  post.body.toLowerCase().contains(query);
            }).toList();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              // Force refresh posts by calling provider refresh method
              ref.read(postsProvider.notifier).refresh();
            },
          ),
        ],
        // Bottom area of AppBar contains search text field for filtering posts
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                // Update local state searchQuery which triggers UI rebuild with filtering
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      // Body displays posts list or loading/error UI based on provider state
      body: postsAsyncValue.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()), // Show spinner
        error: (error, _) => Center(
            child: Text('Error fetching posts: $error')), // Show error message

        data: (_) {
          if (filteredPosts.isEmpty) {
            // If filtering yields no results, show placeholder text
            return const Center(child: Text('No posts found.'));
          }

          // Display posts in a scrollable list
          // Wrapped in RefreshIndicator to enable pull-to-refresh feature
          return RefreshIndicator(
            onRefresh: () => ref.read(postsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return PostCard(post: post);
              },
            ),
          );
        },
      ),
      // Floating action button to open dialog for creating a new post
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show create post dialog on FAB tap
          await showDialog(
            context: context,
            builder: (context) => const CreatePostDialog(),
          );
        },
        tooltip: 'Create new post',
        child: const Icon(Icons.add),
      ),
    );
  }
}
