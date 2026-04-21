import 'package:flutter/material.dart';

class LoadingErrorView extends StatelessWidget {
  const LoadingErrorView({required this.isLoading, required this.error, required this.child, super.key});

  final bool isLoading;
  final String? error;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Text(
          error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }
    return child;
  }
}
