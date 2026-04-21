import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_mapper.dart';
import '../../character/domain/character_controller.dart';
import '../data/quest_repository.dart';
import 'quest_models.dart';

class QuestStateView {
  const QuestStateView({this.loading = false, this.error, this.quests = const []});

  final bool loading;
  final String? error;
  final List<QuestStateModel> quests;

  QuestStateView copyWith({bool? loading, String? error, List<QuestStateModel>? quests}) {
    return QuestStateView(
      loading: loading ?? this.loading,
      error: error,
      quests: quests ?? this.quests,
    );
  }
}

class QuestController extends StateNotifier<QuestStateView> {
  QuestController(this._repo, this._characterController) : super(const QuestStateView());

  final QuestRepository _repo;
  final CharacterController _characterController;

  Future<void> load() async {
    final character = _characterController.state.character;
    if (character == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final quests = await _repo.fetchQuestStates(character.id);
      state = state.copyWith(loading: false, quests: quests);
    } catch (e) {
      state = state.copyWith(loading: false, error: humanizeError(e, fallback: 'No se pudieron cargar las quests.'));
    }
  }

  Future<void> touchNpcQuest(String npcId) async {
    final character = _characterController.state.character;
    if (character == null) return;

    if (npcId == 'npc_sir_edric') {
      await _repo.advanceQuest(character.id, 'quest_sir_edric');
    } else if (npcId == 'npc_guardian_veiled') {
      await _repo.advanceQuest(character.id, 'quest_guardian_relic');
    }
    await load();
  }

  Future<void> completeGuardianQuest() async {
    final character = _characterController.state.character;
    if (character == null) return;
    await _repo.advanceQuest(
      character.id,
      'quest_guardian_relic',
      status: 'completed',
      notes: 'El guardián cayó y la reliquia fue reclamada.',
    );
    await load();
  }

  Future<void> deliverBlackenedEmber() async {
    final character = _characterController.state.character;
    if (character == null) return;
    await _repo.advanceQuest(character.id, 'quest_blacksmith_ember', notes: 'Ascua entregada a Derran.');
    await load();
  }
}

final questRepositoryProvider = Provider<QuestRepository>((ref) => QuestRepository());

final questControllerProvider = StateNotifierProvider<QuestController, QuestStateView>((ref) {
  return QuestController(ref.watch(questRepositoryProvider), ref.read(characterControllerProvider.notifier));
});
