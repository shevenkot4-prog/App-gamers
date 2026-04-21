import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/quest_models.dart';

class QuestRepository {
  SupabaseClient get _client => Supabase.instance.client;

  static const requiredQuestCodes = [
    'quest_sir_edric',
    'quest_blacksmith_ember',
    'quest_guardian_relic',
  ];

  Future<List<QuestStateModel>> fetchQuestStates(String characterId) async {
    final rows = await _client
        .from('character_quest_states')
        .select('quest_code,stage,status,notes,quests_catalog(name,description,reward_text)')
        .eq('character_id', characterId);

    final loaded = rows.map<QuestStateModel>((row) {
      final catalog = row['quests_catalog'] as Map<String, dynamic>?;
      return QuestStateModel(
        questCode: row['quest_code'] as String,
        stage: (row['stage'] as num?)?.toInt() ?? 0,
        status: row['status'] as String? ?? 'active',
        notes: row['notes'] as String?,
        name: catalog?['name'] as String?,
        description: catalog?['description'] as String?,
        reward: catalog?['reward_text'] as String?,
      );
    }).toList();

    return _mergeMissingQuests(loaded);
  }

  List<QuestStateModel> _mergeMissingQuests(List<QuestStateModel> loaded) {
    final byCode = {for (final q in loaded) q.questCode: q};
    final out = <QuestStateModel>[];
    for (final code in requiredQuestCodes) {
      out.add(
        byCode[code] ??
            QuestStateModel(
              questCode: code,
              stage: 0,
              status: 'not_started',
              name: _fallbackName(code),
              description: _fallbackDescription(code),
            ),
      );
    }

    for (final quest in loaded) {
      if (!requiredQuestCodes.contains(quest.questCode)) out.add(quest);
    }

    return out;
  }

  String _fallbackName(String code) {
    switch (code) {
      case 'quest_sir_edric':
        return 'Juramento de Sir Edric';
      case 'quest_blacksmith_ember':
        return 'Ascua para Derran';
      case 'quest_guardian_relic':
        return 'Reliquia del Guardián';
      default:
        return code;
    }
  }

  String _fallbackDescription(String code) {
    switch (code) {
      case 'quest_sir_edric':
        return 'Habla con Sir Edric y sigue su guía en el Santuario.';
      case 'quest_blacksmith_ember':
        return 'Encuentra y entrega el Ascua Ennegrecida al herrero.';
      case 'quest_guardian_relic':
        return 'Derrota al Guardián y reclama su legado.';
      default:
        return 'Sin descripción.';
    }
  }

  Future<void> ensureQuestExists(String characterId, String questCode) async {
    final existing = await _client
        .from('character_quest_states')
        .select('quest_code')
        .eq('character_id', characterId)
        .eq('quest_code', questCode)
        .maybeSingle();
    if (existing != null) return;

    await _client.from('character_quest_states').insert({
      'character_id': characterId,
      'quest_code': questCode,
      'stage': 0,
      'status': 'active',
      'notes': null,
    });
  }

  Future<void> advanceQuest(String characterId, String questCode, {String? status, String? notes}) async {
    await ensureQuestExists(characterId, questCode);
    final current = await _client
        .from('character_quest_states')
        .select('stage')
        .eq('character_id', characterId)
        .eq('quest_code', questCode)
        .single();
    final next = ((current['stage'] as num?)?.toInt() ?? 0) + 1;

    await _client
        .from('character_quest_states')
        .update({
          'stage': next,
          if (status != null) 'status': status,
          if (notes != null) 'notes': notes,
        })
        .eq('character_id', characterId)
        .eq('quest_code', questCode);
  }
}
