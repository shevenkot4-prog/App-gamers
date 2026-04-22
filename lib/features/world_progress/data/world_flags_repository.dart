import 'package:supabase_flutter/supabase_flutter.dart';

class WorldFlagsRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<Map<String, dynamic>> _load(String characterId) async {
    final row = await _client
        .from('world_progress')
        .select('boss_flags,quest_flags,npc_flags')
        .eq('character_id', characterId)
        .maybeSingle();
    return row ?? {};
  }

  Future<void> setBossDefeated(String characterId, String bossCode) async {
    final row = await _load(characterId);
    final bossFlags = Map<String, dynamic>.from((row['boss_flags'] as Map<String, dynamic>?) ?? {});
    bossFlags[bossCode] = true;

    await _client.from('world_progress').upsert({
      'character_id': characterId,
      'boss_flags': bossFlags,
      'quest_flags': row['quest_flags'] ?? {},
      'npc_flags': row['npc_flags'] ?? {},
    });
  }
}
