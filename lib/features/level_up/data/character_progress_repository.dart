import '../../character/data/character_repository.dart';
import '../../character/domain/character_stats.dart';
import '../domain/level_models.dart';

class CharacterProgressRepository {
  CharacterProgressRepository(this._characterRepository);

  final CharacterRepository _characterRepository;

  Future<CharacterStats?> loadStats(String characterId) {
    return _characterRepository.fetchStats(characterId);
  }

  int estimatedLevelUpCost(int currentLevel) {
    return 120 + (currentLevel * 45);
  }

  Future<LevelUpResult> levelUp({required String characterId, required String statKey}) async {
    try {
      await _characterRepository.levelUpStat(characterId: characterId, statKey: statKey);
      final stats = await _characterRepository.fetchStats(characterId);
      return LevelUpResult(success: true, message: 'Atributo mejorado.', stats: stats);
    } catch (e) {
      return LevelUpResult(success: false, message: 'No se pudo subir nivel: $e');
    }
  }
}
