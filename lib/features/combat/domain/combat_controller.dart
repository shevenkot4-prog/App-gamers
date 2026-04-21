import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/error_mapper.dart';
import '../../character/data/character_repository.dart';
import '../../character/domain/character_controller.dart';
import '../../encounter/data/encounter_repository.dart';
import '../../encounter/domain/encounter_models.dart';
import '../../quests/domain/quest_controller.dart';
import '../../world_progress/data/world_flags_repository.dart';
import '../data/combat_engine.dart';
import 'combat_models.dart';

class CombatController extends StateNotifier<CombatState> {
  CombatController(
    this._encounterRepo,
    this._engine,
    this._characterRepo,
    this._characterController,
    this._worldFlagsRepo,
    this._questController,
  ) : super(const CombatState());

  final EncounterRepository _encounterRepo;
  final CombatEngine _engine;
  final CharacterRepository _characterRepo;
  final CharacterController _characterController;
  final WorldFlagsRepository _worldFlagsRepo;
  final QuestController _questController;

  Future<void> start(String nodeCode) async {
    state = state.copyWith(loading: true, error: null, actionInProgress: false);
    try {
      final encounter = await _encounterRepo.fetchEncounterByNode(nodeCode);
      final character = _characterController.state.character;
      if (encounter == null || character == null) {
        state = state.copyWith(loading: false, error: 'No se encontró encuentro para este nodo.');
        return;
      }

      final player = CombatantState(
        name: character.name,
        hp: character.currentHp,
        maxHp: character.maxHp,
        stamina: character.currentStamina,
        maxStamina: character.maxStamina,
        estus: character.estusCharges,
        estusMax: character.estusMax,
      );
      final enemy = CombatantState(
        name: encounter.name,
        hp: encounter.hp,
        maxHp: encounter.hp,
        stamina: encounter.stamina,
        maxStamina: encounter.stamina,
        estus: 0,
        estusMax: 0,
      );
      final intent = _engine.nextIntent(encounter.attackPatterns, phaseTwo: false);

      state = state.copyWith(
        loading: false,
        encounter: encounter,
        player: player,
        enemy: enemy,
        intent: intent,
        roundResult: const CombatRoundResult(summary: 'El encuentro comienza.'),
        finished: false,
        playerWon: false,
        playerLost: false,
        phase: 1,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: humanizeError(e, fallback: 'No se pudo iniciar combate.'));
    }
  }

  Future<void> act(CombatAction action) async {
    final encounter = state.encounter;
    final player = state.player;
    final enemy = state.enemy;
    final intent = state.intent;
    if (encounter == null || player == null || enemy == null || intent == null || state.finished || state.actionInProgress) {
      return;
    }

    state = state.copyWith(actionInProgress: true, error: null);
    final resolution = _engine.resolve(
      action: action,
      player: player,
      enemy: enemy,
      intent: intent,
      encounter: encounter,
    );

    var phase = state.phase;
    final nowEnemy = resolution.enemy;
    final nextPlayer = resolution.player;

    if (encounter.isBoss && phase == 1 && nowEnemy.hp <= (nowEnemy.maxHp / 2).round()) {
      phase = 2;
    }

    if (nowEnemy.hp <= 0) {
      final character = _characterController.state.character;
      if (character != null) {
        await _characterRepo.addSouls(characterId: character.id, soulsToAdd: encounter.soulsReward);
        if (encounter.isBoss) {
          if (encounter.bossSoulItemCode != null) {
            await _characterRepo.grantItem(characterId: character.id, itemCode: encounter.bossSoulItemCode!);
          }
          await _worldFlagsRepo.setBossDefeated(character.id, encounter.nodeCode);
          await _questController.completeGuardianQuest();
        }
        await _characterController.refresh();
      }
      state = state.copyWith(
        player: nextPlayer,
        enemy: nowEnemy,
        roundResult: CombatRoundResult(summary: '${resolution.result.summary} Has vencido y ganaste ${encounter.soulsReward} almas.'),
        finished: true,
        playerWon: true,
        phase: phase,
        actionInProgress: false,
      );
      return;
    }

    if (nextPlayer.hp <= 0) {
      final character = _characterController.state.character;
      if (character != null) {
        await _characterRepo.applyDeathAndRespawn(
          characterId: character.id,
          currentSouls: character.souls,
          deathRegion: character.currentRegion,
          deathNode: character.currentNode,
          respawnNode: character.lastBonfireNode,
        );
        await _characterController.refresh();
      }
      state = state.copyWith(
        player: nextPlayer,
        enemy: nowEnemy,
        roundResult: CombatRoundResult(summary: '${resolution.result.summary} Has caído.'),
        finished: true,
        playerLost: true,
        phase: phase,
        actionInProgress: false,
      );
      return;
    }

    final patterns = phase == 2 && encounter.phaseTwoPatterns.isNotEmpty ? encounter.phaseTwoPatterns : encounter.attackPatterns;

    state = state.copyWith(
      player: nextPlayer,
      enemy: nowEnemy,
      intent: _engine.nextIntent(patterns, phaseTwo: phase == 2),
      roundResult: resolution.result,
      phase: phase,
      actionInProgress: false,
    );
  }
}

final combatEngineProvider = Provider<CombatEngine>((ref) => CombatEngine());
final worldFlagsRepositoryProvider = Provider<WorldFlagsRepository>((ref) => WorldFlagsRepository());

final combatControllerProvider = StateNotifierProvider<CombatController, CombatState>((ref) {
  return CombatController(
    ref.watch(encounterRepositoryProvider),
    ref.watch(combatEngineProvider),
    ref.watch(characterRepositoryProvider),
    ref.read(characterControllerProvider.notifier),
    ref.watch(worldFlagsRepositoryProvider),
    ref.read(questControllerProvider.notifier),
  );
});
