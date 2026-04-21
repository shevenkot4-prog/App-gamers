import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/npc_repository.dart';
import 'npc_model.dart';

class NpcState {
  const NpcState({this.loading = false, this.error, this.npcs = const []});

  final bool loading;
  final String? error;
  final List<NpcEntry> npcs;

  NpcState copyWith({bool? loading, String? error, List<NpcEntry>? npcs}) {
    return NpcState(
      loading: loading ?? this.loading,
      error: error,
      npcs: npcs ?? this.npcs,
    );
  }
}

class NpcController extends StateNotifier<NpcState> {
  NpcController(this._repository) : super(const NpcState());

  final NpcRepository _repository;

  Future<void> loadCoreNpcs() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final npcs = await _repository.fetchCoreNpcs();
      state = state.copyWith(loading: false, npcs: npcs);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'No se pudieron cargar NPCs: $e');
    }
  }

  Future<NpcEntry?> getNpc(String id) async {
    return _repository.fetchNpcById(id);
  }
}

final npcRepositoryProvider = Provider<NpcRepository>((ref) {
  return NpcRepository();
});

final npcControllerProvider = StateNotifierProvider<NpcController, NpcState>((ref) {
  return NpcController(ref.watch(npcRepositoryProvider));
});
