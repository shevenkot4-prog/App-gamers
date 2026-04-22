import '../../encounter/domain/encounter_models.dart';

enum CombatAction { lightAttack, heavyAttack, dodge, block, useEstus, castSpell }

class EnemyIntent {
  const EnemyIntent(this.code, this.label);

  final String code;
  final String label;
}

class CombatantState {
  const CombatantState({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.stamina,
    required this.maxStamina,
    required this.estus,
    required this.estusMax,
  });

  final String name;
  final int hp;
  final int maxHp;
  final int stamina;
  final int maxStamina;
  final int estus;
  final int estusMax;

  CombatantState copyWith({int? hp, int? stamina, int? estus}) {
    return CombatantState(
      name: name,
      hp: hp ?? this.hp,
      maxHp: maxHp,
      stamina: stamina ?? this.stamina,
      maxStamina: maxStamina,
      estus: estus ?? this.estus,
      estusMax: estusMax,
    );
  }
}

class CombatRoundResult {
  const CombatRoundResult({required this.summary});
  final String summary;
}

class BloodstainState {
  const BloodstainState({
    this.region,
    this.node,
    this.souls = 0,
  });

  final String? region;
  final String? node;
  final int souls;
}

class CombatState {
  const CombatState({
    this.loading = false,
    this.error,
    this.encounter,
    this.player,
    this.enemy,
    this.intent,
    this.roundResult,
    this.finished = false,
    this.playerWon = false,
    this.playerLost = false,
    this.phase = 1,
    this.actionInProgress = false,
  });

  final bool loading;
  final String? error;
  final EncounterData? encounter;
  final CombatantState? player;
  final CombatantState? enemy;
  final EnemyIntent? intent;
  final CombatRoundResult? roundResult;
  final bool finished;
  final bool playerWon;
  final bool playerLost;
  final int phase;
  final bool actionInProgress;

  CombatState copyWith({
    bool? loading,
    String? error,
    EncounterData? encounter,
    CombatantState? player,
    CombatantState? enemy,
    EnemyIntent? intent,
    CombatRoundResult? roundResult,
    bool? finished,
    bool? playerWon,
    bool? playerLost,
    int? phase,
    bool? actionInProgress,
  }) {
    return CombatState(
      loading: loading ?? this.loading,
      error: error,
      encounter: encounter ?? this.encounter,
      player: player ?? this.player,
      enemy: enemy ?? this.enemy,
      intent: intent ?? this.intent,
      roundResult: roundResult ?? this.roundResult,
      finished: finished ?? this.finished,
      playerWon: playerWon ?? this.playerWon,
      playerLost: playerLost ?? this.playerLost,
      phase: phase ?? this.phase,
      actionInProgress: actionInProgress ?? this.actionInProgress,
    );
  }
}
