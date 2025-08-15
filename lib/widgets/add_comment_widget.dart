import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/comments_provider.dart';

/// Widget to input and submit a new comment for a given post.
/// Manages internal state of the text field and submit button disabling during submission.
class AddCommentWidget extends ConsumerStatefulWidget {
  final int postId; // ID of the post this comment belongs to

  const AddCommentWidget({super.key, required this.postId});

  @override
  ConsumerState<AddCommentWidget> createState() => _AddCommentWidgetState();
}

class _AddCommentWidgetState extends ConsumerState<AddCommentWidget> {
  final _controller = TextEditingController(); // Controller to read input text
  bool _isSubmitting = false; // Tracks if comment is submitting to disable input

  // Handles submission of comment
  void _submit() async {
    final text = _controller.text.trim(); // Trim whitespace

    if (text.isEmpty) return; // Do nothing if input is empty

    setState(() => _isSubmitting = true); // Show loading indicator

    try {
      // Call provider method to optimistically add comment with fixed authorName
      await ref.read(commentsProvider(widget.postId).notifier).addComment(
            body: text,
            authorName: 'Current User', // Replace with actual user data if available
          );

      _controller.clear(); // Clear input field on success
    } catch (e) {
      // Show snackbar with error on failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false); // Reset submitting state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Text input expands to fill available horizontal space
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Add a comment...',
              border: OutlineInputBorder(),
            ),
            minLines: 1,
            maxLines: 3,
            enabled: !_isSubmitting,
          ),
        ),

        // Send icon button triggers comment submission
        IconButton(
          icon: _isSubmitting
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
          onPressed: _isSubmitting ? null : _submit,
          tooltip: 'Post comment',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller to free resources
    super.dispose();
  }
}
