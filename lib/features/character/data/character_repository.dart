import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/character_model.dart';
import '../domain/character_stats.dart';

class CharacterRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<CharacterModel?> fetchActiveCharacter() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from('characters')
        .select('id,name,class,level,souls,humanity,current_hp,max_hp,current_stamina,max_stamina,estus_charges,estus_max,current_region,current_node,last_bonfire_node,is_active')
        .eq('user_id', user.id)
        .eq('is_active', true)
        .maybeSingle();

    if (row == null) return null;

    final worldProgress = await _client
        .from('world_progress')
        .select('current_region,current_node,last_bonfire_node')
        .eq('character_id', row['id'] as String)
        .maybeSingle();

    return CharacterModel.fromMap(row, worldProgress: worldProgress);
  }

  Future<CharacterModel> createCharacter({required String name, required String className}) async {
    await _client.rpc('create_character_mvp', params: {
      'p_name': name,
      'p_class': className,
    });

    final character = await fetchActiveCharacter();
    if (character == null) {
      throw Exception('No se pudo cargar el personaje recién creado.');
    }
    return character;
  }

  Future<void> restAtBonfire(CharacterModel character) async {
    await _client.from('characters').update({
      'current_hp': character.maxHp,
      'current_stamina': character.maxStamina,
      'estus_charges': character.estusMax,
    }).eq('id', character.id);

    await _client.from('world_progress').upsert({
      'character_id': character.id,
      'current_region': character.currentRegion,
      'current_node': character.currentNode,
      'last_bonfire_node': character.currentNode,
    });
  }
  Future<void> updateCurrentLocation({
    required String characterId,
    required String regionCode,
    required String nodeCode,
  }) async {
    await _client.from("characters").update({
      "current_region": regionCode,
      "current_node": nodeCode,
    }).eq("id", characterId);

    await _client.from("world_progress").upsert({
      "character_id": characterId,
      "current_region": regionCode,
      "current_node": nodeCode,
    });
  }

  Future<void> addSouls({required String characterId, required int soulsToAdd}) async {
    final row = await _client.from('characters').select('souls').eq('id', characterId).single();
    final current = (row['souls'] as num?)?.toInt() ?? 0;
    await _client.from('characters').update({'souls': current + soulsToAdd}).eq('id', characterId);
  }

  Future<void> setBloodstain({
    required String characterId,
    required String regionCode,
    required String nodeCode,
    required int souls,
  }) async {
    try {
      await _client.rpc('set_character_bloodstain', params: {
        'p_character_id': characterId,
        'p_region': regionCode,
        'p_node': nodeCode,
        'p_souls': souls,
      });
    } catch (_) {
      await _client.from('world_progress').upsert({
        'character_id': characterId,
        'bloodstain_region': regionCode,
        'bloodstain_node': nodeCode,
        'bloodstain_souls': souls,
      });
    }
  }

  Future<int> recoverBloodstainSouls({required String characterId, required String nodeCode}) async {
    try {
      final result = await _client.rpc('recover_bloodstain_souls', params: {
        'p_character_id': characterId,
        'p_node': nodeCode,
      });
      return (result as num?)?.toInt() ?? 0;
    } catch (_) {
      final progress = await _client
          .from('world_progress')
          .select('bloodstain_node,bloodstain_souls')
          .eq('character_id', characterId)
          .maybeSingle();
      if (progress == null || progress['bloodstain_node'] != nodeCode) return 0;
      final souls = (progress['bloodstain_souls'] as num?)?.toInt() ?? 0;
      if (souls <= 0) return 0;
      await _client.from('world_progress').update({
        'bloodstain_node': null,
        'bloodstain_region': null,
        'bloodstain_souls': 0,
      }).eq('character_id', characterId);
      await addSouls(characterId: characterId, soulsToAdd: souls);
      return souls;
    }
  }

  Future<int> applyDeathAndRespawn({
    required String characterId,
    required int currentSouls,
    required String deathRegion,
    required String deathNode,
    required String respawnNode,
  }) async {
    await setBloodstain(
      characterId: characterId,
      regionCode: deathRegion,
      nodeCode: deathNode,
      souls: currentSouls,
    );

    final row = await _client
        .from('characters')
        .select('max_hp,max_stamina,estus_max')
        .eq('id', characterId)
        .single();

    await _client.from('characters').update({
      'souls': 0,
      'current_hp': row['max_hp'],
      'current_stamina': row['max_stamina'],
      'estus_charges': row['estus_max'],
      'current_node': respawnNode,
      'status': 'alive',
    }).eq('id', characterId);

    return currentSouls;
  }

  Future<CharacterStats?> fetchStats(String characterId) async {
    final row = await _client
        .from('character_stats')
        .select('vitality,attunement,endurance,strength,dexterity,resistance,intelligence,faith,humanity_stat')
        .eq('character_id', characterId)
        .maybeSingle();
    if (row == null) return null;
    return CharacterStats.fromMap(row);
  }

  Future<void> levelUpStat({required String characterId, required String statKey}) async {
    await _client.rpc('level_up_character', params: {
      'p_character_id': characterId,
      'p_stat': statKey,
    });
  }

  Future<void> grantItem({required String characterId, required String itemCode, int quantity = 1}) async {
    final existing = await _client
        .from('inventory_items')
        .select('id,quantity')
        .eq('character_id', characterId)
        .eq('item_code', itemCode)
        .maybeSingle();

    if (existing == null) {
      await _client.from('inventory_items').insert({
        'character_id': characterId,
        'item_code': itemCode,
        'quantity': quantity,
        'upgrade_level': 0,
        'is_equipped': false,
      });
    } else {
      final current = (existing['quantity'] as num?)?.toInt() ?? 0;
      await _client.from('inventory_items').update({'quantity': current + quantity}).eq('id', existing['id'] as String);
    }
  }
}
