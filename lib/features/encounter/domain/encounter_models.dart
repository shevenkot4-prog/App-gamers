class EncounterData {
  const EncounterData({
    required this.nodeCode,
    required this.name,
    required this.description,
    required this.isBoss,
    required this.hp,
    required this.stamina,
    required this.damageMin,
    required this.damageMax,
    required this.soulsReward,
    required this.attackPatterns,
    this.phaseTwoPatterns = const [],
    this.bossSoulItemCode,
  });

  final String nodeCode;
  final String name;
  final String description;
  final bool isBoss;
  final int hp;
  final int stamina;
  final int damageMin;
  final int damageMax;
  final int soulsReward;
  final List<String> attackPatterns;
  final List<String> phaseTwoPatterns;
  final String? bossSoulItemCode;
}
