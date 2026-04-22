import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../character/domain/character_controller.dart';
import '../domain/level_up_controller.dart';

class LevelUpScreen extends ConsumerStatefulWidget {
  const LevelUpScreen({super.key});

  @override
  ConsumerState<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends ConsumerState<LevelUpScreen> {
  static const statMap = {
    'Vitalidad': 'vitality',
    'Aprendizaje': 'attunement',
    'Aguante': 'endurance',
    'Fuerza': 'strength',
    'Destreza': 'dexterity',
    'Resistencia': 'resistance',
    'Inteligencia': 'intelligence',
    'Fe': 'faith',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(levelUpControllerProvider.notifier).loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final character = ref.watch(characterControllerProvider).character;
    final state = ref.watch(levelUpControllerProvider);
    final stats = state.stats?.asMapEs() ?? const <String, int>{};

    return AshenScaffold(
      title: 'Subir Nivel',
      child: character == null
          ? const Center(child: Text('Sin personaje activo.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nivel: ${character.level}'),
                Text('Almas: ${character.souls}'),
                Text('Costo estimado próximo nivel: ${state.nextLevelCost}'),
                const SizedBox(height: 10),
                if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                if (state.message != null) Text(state.message!, style: const TextStyle(color: Colors.greenAccent)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: statMap.entries.map((entry) {
                      return Card(
                        child: ListTile(
                          title: Text(entry.key),
                          subtitle: Text('Valor: ${stats[entry.key] ?? 0}'),
                          trailing: ElevatedButton(
                            onPressed: state.loading || character.souls < state.nextLevelCost
                                ? null
                                : () => ref.read(levelUpControllerProvider.notifier).levelUp(entry.value),
                            child: const Text('+1'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                OutlinedButton(onPressed: () => context.go('/bonfire'), child: const Text('Volver a hoguera')),
              ],
            ),
    );
  }
}
