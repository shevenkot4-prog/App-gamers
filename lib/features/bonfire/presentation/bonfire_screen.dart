import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../bonfire/domain/bonfire_controller.dart';
import '../../character/domain/character_controller.dart';

class BonfireScreen extends ConsumerWidget {
  const BonfireScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonfireState = ref.watch(bonfireControllerProvider);
    final character = ref.watch(characterControllerProvider).character;

    return AshenScaffold(
      title: 'Hoguera',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Una llama quieta respira entre ceniza y piedra.'),
          const SizedBox(height: 8),
          if (character != null)
            Text('HP ${character.currentHp}/${character.maxHp} · Aguante ${character.currentStamina}/${character.maxStamina} · Estus ${character.estusCharges}/${character.estusMax}'),
          const SizedBox(height: 16),
          if (bonfireState.error != null)
            Text(bonfireState.error!, style: const TextStyle(color: Colors.redAccent)),
          if (bonfireState.message != null)
            Text(bonfireState.message!, style: const TextStyle(color: Colors.greenAccent)),
          ElevatedButton(
            onPressed: bonfireState.loading ? null : () => ref.read(bonfireControllerProvider.notifier).rest(),
            child: const Text('Descansar'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () {}, child: const Text('Viajar (Próximamente)')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => context.go('/level-up'), child: const Text('Subir nivel')),
          const Spacer(),
          OutlinedButton(
            onPressed: () => context.go('/hub'),
            child: const Text('Salir al Santuario'),
          ),
        ],
      ),
    );
  }
}
