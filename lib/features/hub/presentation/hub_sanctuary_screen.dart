import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/ashen_scaffold.dart';
import '../../auth/domain/auth_controller.dart';
import '../../character/domain/character_controller.dart';
import '../../npc/domain/npc_controller.dart';
import '../../quests/domain/quest_controller.dart';

class HubSanctuaryScreen extends ConsumerStatefulWidget {
  const HubSanctuaryScreen({super.key});

  @override
  ConsumerState<HubSanctuaryScreen> createState() => _HubSanctuaryScreenState();
}

class _HubSanctuaryScreenState extends ConsumerState<HubSanctuaryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(characterControllerProvider.notifier).loadActiveCharacter();
      await ref.read(npcControllerProvider.notifier).loadCoreNpcs();
      await ref.read(questControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final characterState = ref.watch(characterControllerProvider);
    final npcState = ref.watch(npcControllerProvider);
    final questState = ref.watch(questControllerProvider);

    return AshenScaffold(
      title: AppStrings.hubName,
      actions: [
        IconButton(
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).logout();
            ref.read(characterControllerProvider.notifier).clearCharacter();
            if (mounted) context.go('/menu');
          },
          icon: const Icon(Icons.logout),
        ),
      ],
      child: characterState.loading
          ? const Center(child: CircularProgressIndicator())
          : characterState.error != null
              ? Center(child: Text(characterState.error!, style: const TextStyle(color: Colors.redAccent)))
              : characterState.character == null
                  ? Column(
                      children: [
                        const Text('No hay personaje activo para esta cuenta.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.go('/character/class'),
                          child: const Text('Crear personaje'),
                        ),
                      ],
                    )
                  : ListView(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${characterState.character!.name} · ${characterState.character!.characterClass}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text('Nivel ${characterState.character!.level} · Almas ${characterState.character!.souls} · Humanidad ${characterState.character!.humanity}'),
                                Text('HP ${characterState.character!.currentHp}/${characterState.character!.maxHp}'),
                                Text('Aguante ${characterState.character!.currentStamina}/${characterState.character!.maxStamina}'),
                                Text('Estus ${characterState.character!.estusCharges}/${characterState.character!.estusMax}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _HubAction(label: 'Hoguera', onTap: () => context.go('/bonfire')),
                            _HubAction(label: 'Inventario', onTap: () => context.go('/inventory')),
                            _HubAction(label: 'Equipo', onTap: () => context.go('/equipment')),
                            _HubAction(label: 'Herrero', onTap: () => context.go('/blacksmith')),
                            _HubAction(label: 'Quests', onTap: () => context.go('/quests')),
                            _HubAction(label: 'Salir al mapa', onTap: () => context.go('/map')),
                          ],
                        ),
                        const SizedBox(height: 16),

                        const SizedBox(height: 16),
                        Text('Quests', style: Theme.of(context).textTheme.titleMedium),
                        if (questState.loading)
                          const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())
                        else if (questState.quests.isEmpty)
                          const Text('Sin quests activas aún.')
                        else
                          ...questState.quests.take(3).map((q) => Text('${q.name ?? q.questCode}: ${q.status} (stage ${q.stage})')),
                        Text('NPCs', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (npcState.loading)
                          const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                        else if (npcState.error != null)
                          Text(npcState.error!, style: const TextStyle(color: Colors.redAccent))
                        else
                          ...npcState.npcs.map(
                            (npc) => Card(
                              child: ListTile(
                                title: Text(npc.name),
                                subtitle: Text(npc.title ?? ''),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.push('/npc/${npc.id}'),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }
}

class _HubAction extends StatelessWidget {
  const _HubAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onTap, child: Text(label, textAlign: TextAlign.center));
  }
}
