class CharacterModel {
  const CharacterModel({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.level,
    required this.souls,
    required this.humanity,
    required this.currentHp,
    required this.maxHp,
    required this.currentStamina,
    required this.maxStamina,
    required this.estusCharges,
    required this.estusMax,
    required this.currentRegion,
    required this.currentNode,
    required this.lastBonfireNode,
  });

  final String id;
  final String name;
  final String characterClass;
  final int level;
  final int souls;
  final int humanity;
  final int currentHp;
  final int maxHp;
  final int currentStamina;
  final int maxStamina;
  final int estusCharges;
  final int estusMax;
  final String currentRegion;
  final String currentNode;
  final String lastBonfireNode;

  CharacterModel copyWith({
    int? currentHp,
    int? currentStamina,
    int? estusCharges,
    String? currentRegion,
    String? currentNode,
    String? lastBonfireNode,
  }) {
    return CharacterModel(
      id: id,
      name: name,
      characterClass: characterClass,
      level: level,
      souls: souls,
      humanity: humanity,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp,
      currentStamina: currentStamina ?? this.currentStamina,
      maxStamina: maxStamina,
      estusCharges: estusCharges ?? this.estusCharges,
      estusMax: estusMax,
      currentRegion: currentRegion ?? this.currentRegion,
      currentNode: currentNode ?? this.currentNode,
      lastBonfireNode: lastBonfireNode ?? this.lastBonfireNode,
    );
  }

  factory CharacterModel.fromMap(Map<String, dynamic> row, {Map<String, dynamic>? worldProgress}) {
    final region = worldProgress?['current_region'] as String? ?? row['current_region'] as String?;
    final node = worldProgress?['current_node'] as String? ?? row['current_node'] as String?;
    final lastBonfire =
        worldProgress?['last_bonfire_node'] as String? ?? row['last_bonfire_node'] as String?;

    return CharacterModel(
      id: row['id'] as String,
      name: row['name'] as String? ?? 'Sin nombre',
      characterClass: row['class'] as String? ?? 'Desconocida',
      level: (row['level'] as num?)?.toInt() ?? 1,
      souls: (row['souls'] as num?)?.toInt() ?? 0,
      humanity: (row['humanity'] as num?)?.toInt() ?? 0,
      currentHp: (row['current_hp'] as num?)?.toInt() ?? 100,
      maxHp: (row['max_hp'] as num?)?.toInt() ?? 100,
      currentStamina: (row['current_stamina'] as num?)?.toInt() ?? 100,
      maxStamina: (row['max_stamina'] as num?)?.toInt() ?? 100,
      estusCharges: (row['estus_charges'] as num?)?.toInt() ?? 3,
      estusMax: (row['estus_max'] as num?)?.toInt() ?? 3,
      currentRegion: region ?? 'ashen_sanctuary',
      currentNode: node ?? 'ashen_sanctuary_01',
      lastBonfireNode: lastBonfire ?? 'ashen_sanctuary_01',
    );
  }
}
