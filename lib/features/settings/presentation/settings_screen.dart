import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../auth/domain/auth_controller.dart';
import '../../character/domain/character_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return AshenScaffold(
      title: 'Ajustes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Configura SUPABASE_URL y SUPABASE_ANON_KEY en el archivo .env'),
          const SizedBox(height: 16),
          if (authState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(authState.error!, style: const TextStyle(color: Colors.redAccent)),
            ),
          ElevatedButton(
            onPressed: authState.loading
                ? null
                : () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    ref.read(characterControllerProvider.notifier).clearCharacter();
                    if (context.mounted) context.go('/menu');
                  },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
