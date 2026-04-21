import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../character/domain/character_controller.dart';
import '../../map/domain/map_controller.dart';

class DeathScreen extends ConsumerWidget {
  const DeathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(characterControllerProvider).character;
    final lost = ref.watch(mapControllerProvider).worldProgress?.bloodstainSouls ?? 0;

    return AshenScaffold(
      title: 'Derrota',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('HAS PERECIDO', style: TextStyle(fontSize: 42, color: Colors.redAccent, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text('Almas perdidas: $lost'),
          if (character != null) Text('Última hoguera: ${character.lastBonfireNode}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/bonfire'),
            child: const Text('Reaparecer'),
          ),
        ],
      ),
    );
  }
}
