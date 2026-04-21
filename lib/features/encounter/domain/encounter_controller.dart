import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_mapper.dart';
import '../data/encounter_repository.dart';
import 'encounter_models.dart';

class EncounterState {
  const EncounterState({this.loading = false, this.error, this.encounter});

  final bool loading;
  final String? error;
  final EncounterData? encounter;

  EncounterState copyWith({bool? loading, String? error, EncounterData? encounter}) {
    return EncounterState(
      loading: loading ?? this.loading,
      error: error,
      encounter: encounter ?? this.encounter,
    );
  }
}

class EncounterController extends StateNotifier<EncounterState> {
  EncounterController(this._repository) : super(const EncounterState());

  final EncounterRepository _repository;

  Future<void> loadEncounter(String nodeCode) async {
    if (nodeCode.isEmpty) {
      state = state.copyWith(error: 'Nodo inválido para encuentro.');
      return;
    }
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await _repository.fetchEncounterByNode(nodeCode);
      if (data == null) {
        state = state.copyWith(loading: false, error: 'No hay encuentro en este nodo.');
        return;
      }
      state = state.copyWith(loading: false, encounter: data);
    } catch (e) {
      state = state.copyWith(loading: false, error: humanizeError(e, fallback: 'No se pudo cargar el encuentro.'));
    }
  }
}

final encounterControllerProvider = StateNotifierProvider<EncounterController, EncounterState>((ref) {
  return EncounterController(ref.watch(encounterRepositoryProvider));
});
