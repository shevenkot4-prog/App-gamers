import '../../character/domain/character_stats.dart';

class LevelUpResult {
  const LevelUpResult({
    required this.success,
    this.message,
    this.stats,
  });

  final bool success;
  final String? message;
  final CharacterStats? stats;
}
