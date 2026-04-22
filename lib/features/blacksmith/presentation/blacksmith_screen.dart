import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../quests/domain/quest_controller.dart';
import '../domain/blacksmith_controller.dart';

class BlacksmithScreen extends ConsumerStatefulWidget {
  const BlacksmithScreen({super.key});

  @override
  ConsumerState<BlacksmithScreen> createState() => _BlacksmithScreenState();
}

class _BlacksmithScreenState extends ConsumerState<BlacksmithScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(questControllerProvider.notifier).load();
      await ref.read(blacksmithControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blacksmithControllerProvider);

    return AshenScaffold(
      title: 'Derran de Astor',
      child: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('"El acero obedece a quien conoce su límite."'),
                const SizedBox(height: 8),
                if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                if (state.message != null) Text(state.message!, style: const TextStyle(color: Colors.greenAccent)),
                Text('Titanita Normal: ${state.materials['material_titanite_shard'] ?? 0}'),
                Text('Titanita Grande: ${state.materials['material_large_titanite_shard'] ?? 0}'),
                Text('Ascua Ennegrecida: ${state.materials['material_blackened_ember'] ?? 0}'),
                const SizedBox(height: 8),
                if ((state.materials['material_blackened_ember'] ?? 0) > 0)
                  ElevatedButton(
                    onPressed: state.loading ? null : () => ref.read(blacksmithControllerProvider.notifier).deliverEmber(),
                    child: const Text('Entregar Ascua Ennegrecida'),
                  ),
                const SizedBox(height: 8),
                const Text('Armas'),
                Expanded(
                  child: state.weapons.isEmpty
                      ? const Center(child: Text('No hay armas mejorables en inventario.'))
                      : ListView(
                    children: state.weapons.map((weapon) {
                      return Card(
                        child: ListTile(
                          title: Text('${weapon.name} +${weapon.upgradeLevel}'),
                          subtitle: Text('Tipo: ${weapon.itemType}'),
                          trailing: ElevatedButton(
                            onPressed: state.loading ? null : () => ref.read(blacksmithControllerProvider.notifier).upgrade(weapon),
                            child: const Text('Mejorar'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                OutlinedButton(onPressed: () => context.go('/hub'), child: const Text('Volver al santuario')),
              ],
            ),
    );
  }
}
