import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_mapper.dart';
import '../../character/domain/character_controller.dart';
import '../../character/domain/character_stats.dart';
import '../data/character_progress_repository.dart';

class LevelUpState {
  const LevelUpState({this.loading = false, this.error, this.message, this.stats, this.nextLevelCost = 0});

  final bool loading;
  final String? error;
  final String? message;
  final CharacterStats? stats;
  final int nextLevelCost;

  LevelUpState copyWith({
    bool? loading,
    String? error,
    String? message,
    CharacterStats? stats,
    int? nextLevelCost,
  }) {
    return LevelUpState(
      loading: loading ?? this.loading,
      error: error,
      message: message,
      stats: stats ?? this.stats,
      nextLevelCost: nextLevelCost ?? this.nextLevelCost,
    );
  }
}

class LevelUpController extends StateNotifier<LevelUpState> {
  LevelUpController(this._repo, this._characterController) : super(const LevelUpState());

  final CharacterProgressRepository _repo;
  final CharacterController _characterController;

  Future<void> loadStats() async {
    final character = _characterController.state.character;
    if (character == null) return;
    state = state.copyWith(loading: true, error: null, message: null);
    try {
      final stats = await _repo.loadStats(character.id);
      state = state.copyWith(
        loading: false,
        stats: stats,
        nextLevelCost: _repo.estimatedLevelUpCost(character.level),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: humanizeError(e, fallback: 'Error cargando stats.'));
    }
  }

  Future<void> levelUp(String statKey) async {
    final character = _characterController.state.character;
    if (character == null) return;
    final cost = _repo.estimatedLevelUpCost(character.level);
    if (character.souls < cost) {
      state = state.copyWith(error: 'No tienes suficientes almas. Necesitas $cost.', message: null);
      return;
    }

    state = state.copyWith(loading: true, error: null, message: null);

    final result = await _repo.levelUp(characterId: character.id, statKey: statKey);
    await _characterController.refresh();

    if (!result.success) {
      state = state.copyWith(loading: false, error: result.message);
      return;
    }

    final refreshed = _characterController.state.character;
    state = state.copyWith(
      loading: false,
      message: result.message,
      stats: result.stats,
      nextLevelCost: refreshed == null ? cost : _repo.estimatedLevelUpCost(refreshed.level),
    );
  }
}

final characterProgressRepositoryProvider = Provider<CharacterProgressRepository>((ref) {
  return CharacterProgressRepository(ref.watch(characterRepositoryProvider));
});

final levelUpControllerProvider = StateNotifierProvider<LevelUpController, LevelUpState>((ref) {
  return LevelUpController(
    ref.watch(characterProgressRepositoryProvider),
    ref.read(characterControllerProvider.notifier),
  );
});
