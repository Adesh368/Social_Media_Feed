import 'package:flutter/material.dart';

/// Reusable loading spinner widget to indicate loading state in the UI.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
