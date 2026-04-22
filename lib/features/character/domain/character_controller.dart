import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/character_repository.dart';
import 'character_model.dart';

class CharacterState {
  const CharacterState({this.loading = false, this.error, this.character});

  final bool loading;
  final String? error;
  final CharacterModel? character;

  CharacterState copyWith({bool? loading, String? error, CharacterModel? character}) {
    return CharacterState(
      loading: loading ?? this.loading,
      error: error,
      character: character ?? this.character,
    );
  }
}

class CharacterController extends StateNotifier<CharacterState> {
  CharacterController(this._repository) : super(const CharacterState());

  final CharacterRepository _repository;

  Future<CharacterModel?> loadActiveCharacter() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final character = await _repository.fetchActiveCharacter();
      state = state.copyWith(loading: false, character: character);
      return character;
    } catch (e) {
      state = state.copyWith(loading: false, error: 'No se pudo cargar personaje: $e');
      return null;
    }
  }

  Future<CharacterModel?> refresh() async {
    return loadActiveCharacter();
  }

  Future<CharacterModel?> createCharacter({required String name, required String classCode}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final character = await _repository.createCharacter(name: name, classCode: classCode);
      state = state.copyWith(loading: false, character: character);
      return character;
    } catch (e) {
      state = state.copyWith(loading: false, error: 'No se pudo crear personaje: $e');
      return null;
    }
  }

  Future<bool> restAtBonfire() async {
    final character = state.character;
    if (character == null) return false;

    state = state.copyWith(loading: true, error: null);
    try {
      await _repository.restAtBonfire(character);
      state = state.copyWith(
        loading: false,
        character: character.copyWith(
          currentHp: character.maxHp,
          currentStamina: character.maxStamina,
          estusCharges: character.estusMax,
          lastBonfireNode: character.currentNode,
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: 'No se pudo descansar: $e');
      return false;
    }
  }

  void clearCharacter() {
    state = const CharacterState();
  }
}

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository();
});

final characterControllerProvider = StateNotifierProvider<CharacterController, CharacterState>((ref) {
  return CharacterController(ref.watch(characterRepositoryProvider));
});
