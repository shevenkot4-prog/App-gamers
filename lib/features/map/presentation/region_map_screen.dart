import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../domain/map_controller.dart';
import '../domain/map_models.dart';

class RegionMapScreen extends ConsumerStatefulWidget {
  const RegionMapScreen({super.key});

  @override
  ConsumerState<RegionMapScreen> createState() => _RegionMapScreenState();
}

class _RegionMapScreenState extends ConsumerState<RegionMapScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(mapControllerProvider.notifier).loadMap());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapControllerProvider);
    final controller = ref.read(mapControllerProvider.notifier);
    final connected = controller.connectedNodes();

    return AshenScaffold(
      title: 'Mapa por Nodos',
      child: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)))
              : state.currentNode == null
                  ? const Center(child: Text('No hay nodo actual disponible.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.region?.name ?? 'Región desconocida', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(state.region?.description ?? 'Sin descripción'),
                        const SizedBox(height: 12),

                        if ((state.notice ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(state.notice!, style: const TextStyle(color: Colors.greenAccent)),
                          ),
                        Card(
                          child: ListTile(
                            title: Text('Nodo actual: ${state.currentNode!.name}'),
                            subtitle: Text(state.currentNode!.description),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.worldProgress?.bloodstainNode != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Bloodstain: ${state.worldProgress!.bloodstainNode} (${state.worldProgress!.bloodstainSouls} almas)',
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        Text('Rutas disponibles', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Expanded(
                          child: connected.isEmpty
                              ? const Center(child: Text('No hay conexiones desde este nodo.'))
                              : ListView.builder(
                                  itemCount: connected.length,
                                  itemBuilder: (context, index) {
                                    final node = connected[index];
                                    final edge = controller.edgeToNode(node.code);
                                    return Card(
                                      child: ListTile(
                                        title: Text(node.name),
                                        subtitle: Text(
                                          '${_spanishType(node.nodeType)} · ${node.description}\n'
                                          '${edge?.isLocked == true ? 'Bloqueado: ${edge?.lockCode ?? 'sin clave'}' : 'Accesible'}'
                                          '${edge?.isShortcut == true ? ' · Shortcut' : ''}',
                                        ),
                                        isThreeLine: true,
                                        trailing: _nodeBadge(node, edge),
                                        onTap: edge?.isLocked == true ? null : () => _onNodeTap(node),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        OutlinedButton(
                          onPressed: () => context.go('/hub'),
                          child: const Text('Volver al Santuario'),
                        ),
                      ],
                    ),
    );
  }

  Widget _nodeBadge(MapNode node, NodeEdgeModel? edge) {
    if (edge?.isLocked == true) {
      return const Icon(Icons.lock, color: Colors.orangeAccent);
    }
    if (node.nodeType == NodeType.boss) {
      return const Icon(Icons.warning_amber_rounded, color: Colors.redAccent);
    }
    if (edge?.isShortcut == true) {
      return const Icon(Icons.flash_on, color: Colors.cyanAccent);
    }
    return const Icon(Icons.chevron_right);
  }

  Future<void> _onNodeTap(MapNode node) async {
    final destination = await ref.read(mapControllerProvider.notifier).moveToNode(node);
    if (!mounted || destination == null) return;

    switch (destination) {
      case MapDestination.bonfire:
        context.go('/bonfire');
        return;
      case MapDestination.npc:
        context.go('/npc/${node.npcCode ?? 'npc_guardian_veiled'}');
        return;
      case MapDestination.encounter:
        context.go('/encounter?node=${node.code}');
        return;
      case MapDestination.boss:
        context.go('/encounter?node=${node.code}');
        return;
      case MapDestination.event:
        context.go('/event?node=${node.code}');
        return;
      case MapDestination.loot:
        context.go('/loot?node=${node.code}');
        return;
      case MapDestination.hub:
        context.go('/hub');
        return;
      case MapDestination.map:
        return;
    }
  }

  String _spanishType(NodeType type) {
    switch (type) {
      case NodeType.combat:
        return 'Combate';
      case NodeType.event:
        return 'Evento';
      case NodeType.loot:
        return 'Botín';
      case NodeType.npc:
        return 'NPC';
      case NodeType.bonfire:
        return 'Hoguera';
      case NodeType.boss:
        return 'Jefe';
      case NodeType.shortcut:
        return 'Shortcut';
      case NodeType.hub:
        return 'Hub';
      default:
        return 'Desconocido';
    }
  }
}
