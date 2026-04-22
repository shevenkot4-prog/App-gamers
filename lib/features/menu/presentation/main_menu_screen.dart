import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../auth/domain/auth_controller.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSession = ref.watch(authRepositoryProvider).currentSession != null;

    return AshenScaffold(
      title: 'Menú Principal',
      child: Column(
        children: [
          const Spacer(),
          ElevatedButton(
            onPressed: () => context.go(hasSession ? '/' : '/auth'),
            child: Text(hasSession ? 'Continuar partida' : 'Entrar al Reino'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.go('/settings'),
            child: const Text('Ajustes'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
