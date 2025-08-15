import 'package:flutter/material.dart';
import '../models/comment.dart';

/// Widget representing a single comment in a list.
/// Displays the comment body and author name with icon.
class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.comment),
      title: Text(comment.body),
      subtitle: Text('— ${comment.authorName}'),
    );
  }
}
