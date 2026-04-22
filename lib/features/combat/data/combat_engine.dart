import 'dart:math';

import '../../encounter/domain/encounter_models.dart';
import '../domain/combat_models.dart';

class CombatEngine {
  final _rng = Random();

  EnemyIntent nextIntent(List<String> pattern, {required bool phaseTwo}) {
    final list = pattern.isEmpty ? ['quick_slash'] : pattern;
    final code = list[_rng.nextInt(list.length)];
    return EnemyIntent(code, _label(code, phaseTwo));
  }

  CombatResolution resolve({
    required CombatAction action,
    required CombatantState player,
    required CombatantState enemy,
    required EnemyIntent intent,
    required EncounterData encounter,
  }) {
    var pHp = player.hp;
    var pSt = player.stamina;
    var pEstus = player.estus;
    var eHp = enemy.hp;

    var outgoingDamage = 0;
    var incomingDamage = _intentBaseDamage(intent.code, encounter);
    var summary = '';

    switch (action) {
      case CombatAction.lightAttack:
        if (pSt >= 14) {
          outgoingDamage = 15 + _rng.nextInt(5);
          pSt -= 14;
          summary = 'Atacas con rapidez.';
        } else {
          summary = 'Acción fallida: no tienes aguante para ataque ligero.';
        }
        break;
      case CombatAction.heavyAttack:
        if (pSt >= 28) {
          outgoingDamage = 24 + _rng.nextInt(7);
          pSt -= 28;
          incomingDamage += 3;
          summary = 'Lanzas un golpe pesado.';
        } else {
          summary = 'Acción fallida: aguante insuficiente para golpe pesado.';
        }
        break;
      case CombatAction.dodge:
        if (pSt >= 18) {
          pSt -= 18;
          incomingDamage = (incomingDamage * _dodgeMultiplier(intent.code)).round();
          summary = 'Esquivas con timing ajustado.';
        } else {
          summary = 'Intentas esquivar agotado.';
          incomingDamage += 4;
        }
        break;
      case CombatAction.block:
        if (pSt >= 12) {
          pSt -= 12;
          incomingDamage = (incomingDamage * _blockMultiplier(intent.code)).round();
          summary = 'Bloqueas el impacto enemigo.';
        } else {
          summary = 'Bloque débil por falta de aguante.';
          incomingDamage += 5;
        }
        break;
      case CombatAction.useEstus:
        if (pEstus > 0) {
          pEstus -= 1;
          pHp = min(player.maxHp, pHp + 45);
          incomingDamage += 2;
          summary = 'Bebes Estus bajo presión.';
        } else {
          summary = 'Acción fallida: no quedan cargas de Estus.';
        }
        break;
      case CombatAction.castSpell:
        if (pSt >= 22) {
          pSt -= 22;
          outgoingDamage = 19 + _rng.nextInt(9);
          summary = 'Canalizas un hechizo de ceniza.';
        } else {
          summary = 'Acción fallida: el hechizo se disipa por fatiga.';
        }
        break;
    }

    eHp -= outgoingDamage;
    if (eHp > 0) {
      if (pSt <= 0) incomingDamage += 6;
      pHp -= max(0, incomingDamage);
    }

    pSt = min(player.maxStamina, pSt + 9);

    return CombatResolution(
      player: player.copyWith(hp: max(0, pHp), stamina: max(0, pSt), estus: pEstus),
      enemy: enemy.copyWith(hp: max(0, eHp), stamina: enemy.stamina),
      result: CombatRoundResult(summary: '$summary Intención enemiga: ${intent.label}.'),
    );
  }

  int _intentBaseDamage(String code, EncounterData encounter) {
    final minDamage = encounter.damageMin;
    final maxDamage = max(encounter.damageMin, encounter.damageMax);
    final sampled = minDamage + _rng.nextInt((maxDamage - minDamage) + 1);

    switch (code) {
      case 'guard_break_stab':
        return sampled + 2;
      case 'delayed_cleave':
      case 'sweeping_burn':
        return sampled + 3;
      case 'ranged_shot':
      case 'quick_slash':
      default:
        return sampled;
    }
  }

  double _dodgeMultiplier(String code) {
    if (code == 'quick_slash' || code == 'lunge_bite') return 0.25;
    if (code == 'delayed_cleave' || code == 'heavy_shield_bash') return 0.58;
    return 0.4;
  }

  double _blockMultiplier(String code) {
    if (code == 'guard_break_stab') return 0.82;
    if (code == 'delayed_cleave') return 0.62;
    return 0.5;
  }

  String _label(String code, bool phaseTwo) {
    final suffix = phaseTwo ? ' (Fase II)' : '';
    return '$code$suffix';
  }
}

class CombatResolution {
  const CombatResolution({required this.player, required this.enemy, required this.result});

  final CombatantState player;
  final CombatantState enemy;
  final CombatRoundResult result;
}
