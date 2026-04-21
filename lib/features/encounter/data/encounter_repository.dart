import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/encounter_models.dart';

class EncounterRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<EncounterData?> fetchEncounterByNode(String nodeCode) async {
    final node = await _client
        .from('nodes_catalog')
        .select('code,name,description,node_type,enemy_code,boss_code')
        .eq('code', nodeCode)
        .maybeSingle();

    if (node == null) return null;

    final bossCode = node['boss_code'] as String?;
    if (bossCode != null && bossCode.isNotEmpty) {
      final boss = await _client
          .from('bosses_catalog')
          .select('code,name,intro_text,phase_one_json,phase_two_json,souls_reward,boss_soul_item_code')
          .eq('code', bossCode)
          .single();

      final phaseOne = _patternList(boss['phase_one_json']);
      final phaseTwo = _patternList(boss['phase_two_json']);

      return EncounterData(
        nodeCode: nodeCode,
        name: boss['name'] as String? ?? 'Jefe desconocido',
        description: boss['intro_text'] as String? ?? 'Una presencia antigua te observa.',
        isBoss: true,
        hp: 220,
        stamina: 120,
        damageMin: 16,
        damageMax: 30,
        soulsReward: (boss['souls_reward'] as num?)?.toInt() ?? 500,
        attackPatterns: phaseOne.isEmpty ? const ['delayed_cleave', 'cinder_arc'] : phaseOne,
        phaseTwoPatterns: phaseTwo,
        bossSoulItemCode: boss['boss_soul_item_code'] as String?,
      );
    }

    final enemyCode = node['enemy_code'] as String?;
    if (enemyCode == null || enemyCode.isEmpty) return null;

    final enemy = await _client
        .from('enemies_catalog')
        .select('code,name,kind,hp,stamina,damage_min,damage_max,souls_reward,attack_pattern_json')
        .eq('code', enemyCode)
        .single();

    final patterns = _patternList(enemy['attack_pattern_json']);

    final normalMin = (enemy['damage_min'] as num?)?.toInt() ?? 7;
    final normalMax = (enemy['damage_max'] as num?)?.toInt() ?? 14;

    return EncounterData(
      nodeCode: nodeCode,
      name: enemy['name'] as String? ?? 'Enemigo desconocido',
      description: 'Tipo: ${enemy['kind'] ?? 'hostil'}',
      isBoss: false,
      hp: (enemy['hp'] as num?)?.toInt() ?? 78,
      stamina: (enemy['stamina'] as num?)?.toInt() ?? 75,
      damageMin: normalMin < 6 ? 6 : normalMin,
      damageMax: normalMax > 18 ? 18 : normalMax,
      soulsReward: (enemy['souls_reward'] as num?)?.toInt() ?? 70,
      attackPatterns: patterns.isEmpty ? const ['quick_slash', 'ranged_shot'] : patterns,
    );
  }

  List<String> _patternList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is Map<String, dynamic>) {
      final value = raw['patterns'];
      if (value is List) return value.map((e) => e.toString()).toList();
    }
    return const [];
  }
}

final encounterRepositoryProvider = Provider<EncounterRepository>((ref) => EncounterRepository());
