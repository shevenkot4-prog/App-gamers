enum NodeType { combat, event, loot, npc, bonfire, boss, shortcut, hub, unknown }

enum MapDestination { encounter, bonfire, npc, event, loot, boss, hub, map }

class RegionModel {
  const RegionModel({
    required this.code,
    required this.name,
    required this.description,
    required this.sortOrder,
  });

  final String code;
  final String name;
  final String description;
  final int sortOrder;

  factory RegionModel.fromMap(Map<String, dynamic> row) {
    return RegionModel(
      code: row['code'] as String,
      name: row['name'] as String? ?? row['code'] as String,
      description: row['description'] as String? ?? '',
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class MapNode {
  const MapNode({
    required this.code,
    required this.regionCode,
    required this.name,
    required this.nodeType,
    required this.description,
    required this.sortOrder,
    required this.isBonfire,
    required this.isStartingNode,
    this.enemyCode,
    this.bossCode,
    this.lootTable,
    this.metadata,
    this.npcCode,
  });

  final String code;
  final String regionCode;
  final String name;
  final NodeType nodeType;
  final String description;
  final int sortOrder;
  final bool isBonfire;
  final bool isStartingNode;
  final String? enemyCode;
  final String? bossCode;
  final String? lootTable;
  final Map<String, dynamic>? metadata;
  final String? npcCode;

  factory MapNode.fromMap(Map<String, dynamic> row) {
    return MapNode(
      code: row['code'] as String,
      regionCode: row['region_code'] as String,
      name: row['name'] as String? ?? row['code'] as String,
      nodeType: _nodeTypeFromString(row['node_type'] as String?),
      description: row['description'] as String? ?? '',
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      isBonfire: row['is_bonfire'] as bool? ?? false,
      isStartingNode: row['is_starting_node'] as bool? ?? false,
      enemyCode: row['enemy_code'] as String?,
      bossCode: row['boss_code'] as String?,
      lootTable: row['loot_table'] as String?,
      metadata: row['metadata'] as Map<String, dynamic>?,
      npcCode: row['npc_code'] as String? ?? (row['metadata'] as Map<String, dynamic>? ?? const {})['npc_code'] as String?,
    );
  }
}

class NodeEdgeModel {
  const NodeEdgeModel({
    required this.fromNode,
    required this.toNode,
    required this.isLocked,
    this.lockCode,
    required this.isShortcut,
    this.metadata,
  });

  final String fromNode;
  final String toNode;
  final bool isLocked;
  final String? lockCode;
  final bool isShortcut;
  final Map<String, dynamic>? metadata;

  factory NodeEdgeModel.fromMap(Map<String, dynamic> row) {
    return NodeEdgeModel(
      fromNode: row['from_node'] as String,
      toNode: row['to_node'] as String,
      isLocked: row['is_locked'] as bool? ?? false,
      lockCode: row['lock_code'] as String?,
      isShortcut: row['is_shortcut'] as bool? ?? false,
      metadata: row['metadata'] as Map<String, dynamic>?,
    );
  }
}

class WorldProgressModel {
  const WorldProgressModel({
    required this.discoveredNodes,
    required this.openedShortcuts,
    this.bloodstainRegion,
    this.bloodstainNode,
    this.bloodstainSouls = 0,
  });

  final List<String> discoveredNodes;
  final List<String> openedShortcuts;
  final String? bloodstainRegion;
  final String? bloodstainNode;
  final int bloodstainSouls;

  factory WorldProgressModel.fromMap(Map<String, dynamic> row) {
    return WorldProgressModel(
      discoveredNodes: List<String>.from((row['discovered_nodes'] as List?) ?? const []),
      openedShortcuts: List<String>.from((row['opened_shortcuts'] as List?) ?? const []),
      bloodstainRegion: row['bloodstain_region'] as String?,
      bloodstainNode: row['bloodstain_node'] as String?,
      bloodstainSouls: (row['bloodstain_souls'] as num?)?.toInt() ?? 0,
    );
  }
}

NodeType _nodeTypeFromString(String? value) {
  switch (value) {
    case 'combat':
      return NodeType.combat;
    case 'event':
      return NodeType.event;
    case 'loot':
      return NodeType.loot;
    case 'npc':
      return NodeType.npc;
    case 'bonfire':
      return NodeType.bonfire;
    case 'boss':
      return NodeType.boss;
    case 'shortcut':
      return NodeType.shortcut;
    case 'hub':
      return NodeType.hub;
    default:
      return NodeType.unknown;
  }
}

MapDestination destinationFromNodeType(NodeType type) {
  switch (type) {
    case NodeType.combat:
      return MapDestination.encounter;
    case NodeType.boss:
      return MapDestination.boss;
    case NodeType.bonfire:
      return MapDestination.bonfire;
    case NodeType.npc:
      return MapDestination.npc;
    case NodeType.event:
      return MapDestination.event;
    case NodeType.loot:
      return MapDestination.loot;
    case NodeType.hub:
      return MapDestination.hub;
    default:
      return MapDestination.map;
  }
}
