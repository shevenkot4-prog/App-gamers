class CharacterStats {
  const CharacterStats({
    required this.vitality,
    required this.attunement,
    required this.endurance,
    required this.strength,
    required this.dexterity,
    required this.resistance,
    required this.intelligence,
    required this.faith,
    required this.humanityStat,
  });

  final int vitality;
  final int attunement;
  final int endurance;
  final int strength;
  final int dexterity;
  final int resistance;
  final int intelligence;
  final int faith;
  final int humanityStat;

  factory CharacterStats.fromMap(Map<String, dynamic> row) {
    int read(String key) => (row[key] as num?)?.toInt() ?? 0;
    return CharacterStats(
      vitality: read('vitality'),
      attunement: read('attunement'),
      endurance: read('endurance'),
      strength: read('strength'),
      dexterity: read('dexterity'),
      resistance: read('resistance'),
      intelligence: read('intelligence'),
      faith: read('faith'),
      humanityStat: read('humanity_stat'),
    );
  }

  Map<String, int> asMapEs() {
    return {
      'Vitalidad': vitality,
      'Aprendizaje': attunement,
      'Aguante': endurance,
      'Fuerza': strength,
      'Destreza': dexterity,
      'Resistencia': resistance,
      'Inteligencia': intelligence,
      'Fe': faith,
    };
  }
}
