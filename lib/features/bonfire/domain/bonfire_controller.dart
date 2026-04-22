import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../character/domain/character_controller.dart';
import '../data/bonfire_service.dart';

class BonfireState {
  const BonfireState({this.loading = false, this.message, this.error});

  final bool loading;
  final String? message;
  final String? error;

  BonfireState copyWith({bool? loading, String? message, String? error}) {
    return BonfireState(
      loading: loading ?? this.loading,
      message: message,
      error: error,
    );
  }
}

class BonfireController extends StateNotifier<BonfireState> {
  BonfireController(this._service, this._characterController) : super(const BonfireState());

  final BonfireService _service;
  final CharacterController _characterController;

  Future<void> rest() async {
    final character = _characterController.state.character;
    if (character == null) {
      state = state.copyWith(error: 'No hay personaje activo.');
      return;
    }

    state = state.copyWith(loading: true, error: null, message: null);
    try {
      await _service.rest(character);
      await _characterController.refresh();
      state = state.copyWith(loading: false, message: 'Descansaste en la hoguera.');
    } catch (e) {
      state = state.copyWith(loading: false, error: 'No se pudo descansar: $e');
    }
  }
}

final bonfireServiceProvider = Provider<BonfireService>((ref) {
  return BonfireService(ref.watch(characterRepositoryProvider));
});

final bonfireControllerProvider = StateNotifierProvider<BonfireController, BonfireState>((ref) {
  return BonfireController(ref.watch(bonfireServiceProvider), ref.read(characterControllerProvider.notifier));
});
