import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/posts_provider.dart';

/// Dialog widget that allows user to create a new post by entering title and body.
/// Handles form validation and manages submission state with loading indicator and error handling.
class CreatePostDialog extends ConsumerStatefulWidget {
  const CreatePostDialog({super.key});

  @override
  ConsumerState<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends ConsumerState<CreatePostDialog> {
  final _formKey = GlobalKey<FormState>(); // Key to validate form
  String _title = ''; // Stores title from input
  String _body = ''; // Stores body/content from input
  bool _isSubmitting = false; // Controls loading state and disables input/buttons

  // Form submission handler
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid form inputs; do not proceed
      return;
    }

    _formKey.currentState!.save(); // Save entered values
    setState(() => _isSubmitting = true); // Show loading indicator

    try {
      // Call provider notifier to add post optimistically
      await ref.read(postsProvider.notifier).addPost(
            title: _title,
            body: _body,
            userId: 1, // Replace with actual user ID from auth context if available
          );

      if (mounted) Navigator.of(context).pop(); // Close dialog if successful
    } catch (e) {
      if (mounted) {
        // Show error snackbar on failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false); // Reset submitting state
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title input field with validation
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter a title' : null,
              onSaved: (val) => _title = val ?? '',
              enabled: !_isSubmitting,
            ),

            // Body/content input field with validation
            TextFormField(
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 4,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Enter body content' : null,
              onSaved: (val) => _body = val ?? '',
              enabled: !_isSubmitting,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Post'),
        ),
      ],
    );
  }
}
