import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/domain/auth_controller.dart';
import '../../character/domain/character_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_resolveEntryPoint);
  }

  Future<void> _resolveEntryPoint() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final session = ref.read(authRepositoryProvider).currentSession;
    if (session == null) {
      if (mounted) context.go('/menu');
      return;
    }

    final character = await ref.read(characterControllerProvider.notifier).loadActiveCharacter();
    if (!mounted) return;

    if (character == null) {
      context.go('/character/class');
    } else {
      context.go('/hub');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          AppStrings.appName,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
