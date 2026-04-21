import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../character/data/character_repository.dart';
import '../../character/domain/character_controller.dart';
import '../data/map_repository.dart';
import '../data/world_progress_repository.dart';
import 'map_models.dart';

class MapState {
  const MapState({
    this.loading = false,
    this.error,
    this.notice,
    this.region,
    this.currentNode,
    this.nodes = const [],
    this.connections = const [],
    this.worldProgress,
  });

  final bool loading;
  final String? error;
  final String? notice;
  final RegionModel? region;
  final MapNode? currentNode;
  final List<MapNode> nodes;
  final List<NodeEdgeModel> connections;
  final WorldProgressModel? worldProgress;

  MapState copyWith({
    bool? loading,
    String? error,
    String? notice,
    RegionModel? region,
    MapNode? currentNode,
    List<MapNode>? nodes,
    List<NodeEdgeModel>? connections,
    WorldProgressModel? worldProgress,
  }) {
    return MapState(
      loading: loading ?? this.loading,
      error: error,
      notice: notice,
      region: region ?? this.region,
      currentNode: currentNode ?? this.currentNode,
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      worldProgress: worldProgress ?? this.worldProgress,
    );
  }
}

class MapController extends StateNotifier<MapState> {
  MapController(this._mapRepo, this._worldRepo, this._charRepo, this._charController)
      : super(const MapState());

  final MapRepository _mapRepo;
  final WorldProgressRepository _worldRepo;
  final CharacterRepository _charRepo;
  final CharacterController _charController;

  Future<void> loadMap() async {
    final character = _charController.state.character;
    if (character == null) {
      state = state.copyWith(error: 'No hay personaje activo.');
      return;
    }

    state = state.copyWith(loading: true, error: null);
    try {
      final region = await _mapRepo.fetchRegion(character.currentRegion);
      final nodes = await _mapRepo.fetchRegionNodes(character.currentRegion);
      final edges = await _mapRepo.fetchEdgesFromNode(character.currentNode);
      var world = await _worldRepo.fetchProgress(character.id);
      if (world.bloodstainNode == character.currentNode && world.bloodstainSouls > 0) {
        final recovered = await _charRepo.recoverBloodstainSouls(
          characterId: character.id,
          nodeCode: character.currentNode,
        );
        if (recovered > 0) {
          await _charController.refresh();
          world = await _worldRepo.fetchProgress(character.id);
          state = state.copyWith(notice: 'Recuperaste $recovered almas del bloodstain.');
        }
      }
      final currentNode = _findNode(nodes, character.currentNode);

      state = state.copyWith(
        loading: false,
        error: null,
        region: region,
        nodes: nodes,
        connections: edges,
        worldProgress: world,
        currentNode: currentNode,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: 'No se pudo cargar mapa: $e');
    }
  }

  List<MapNode> connectedNodes() {
    final list = <MapNode>[];
    for (final edge in state.connections) {
      final node = _findNode(state.nodes, edge.toNode);
      if (node != null) list.add(node);
    }
    return list;
  }

  NodeEdgeModel? edgeToNode(String nodeCode) {
    for (final edge in state.connections) {
      if (edge.toNode == nodeCode) return edge;
    }
    return null;
  }

  Future<MapDestination?> moveToNode(MapNode node) async {
    final character = _charController.state.character;
    final edge = edgeToNode(node.code);
    if (character == null || edge == null) {
      state = state.copyWith(notice: 'Ruta no disponible.');
      return null;
    }
    if (edge.isLocked) {
      state = state.copyWith(notice: 'Ruta bloqueada: ${edge.lockCode ?? 'requiere llave'}');
      return null;
    }

    await _charRepo.updateCurrentLocation(
      characterId: character.id,
      regionCode: node.regionCode,
      nodeCode: node.code,
    );

    await _worldRepo.upsertDiscoveredNode(characterId: character.id, nodeCode: node.code);
    await _charController.refresh();
    await loadMap();

    return destinationFromNodeType(node.nodeType);
  }

  MapNode? _findNode(List<MapNode> source, String code) {
    for (final node in source) {
      if (node.code == code) return node;
    }
    return null;
  }
}

final mapRepositoryProvider = Provider<MapRepository>((ref) => MapRepository());
final worldProgressRepositoryProvider = Provider<WorldProgressRepository>((ref) => WorldProgressRepository());

final mapControllerProvider = StateNotifierProvider<MapController, MapState>((ref) {
  return MapController(
    ref.watch(mapRepositoryProvider),
    ref.watch(worldProgressRepositoryProvider),
    ref.watch(characterRepositoryProvider),
    ref.read(characterControllerProvider.notifier),
  );
});
