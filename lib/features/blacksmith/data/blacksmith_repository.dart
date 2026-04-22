import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/blacksmith_models.dart';

class BlacksmithRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<UpgradeableWeaponView>> loadWeapons(String characterId) async {
    final rows = await _client
        .from('inventory_items')
        .select('id,item_code,upgrade_level,items_catalog(name,item_type)')
        .eq('character_id', characterId);

    return rows.map<UpgradeableWeaponView>((row) {
      final cat = row['items_catalog'] as Map<String, dynamic>? ?? {};
      return UpgradeableWeaponView(
        inventoryId: row['id'] as String,
        itemCode: row['item_code'] as String? ?? 'unknown',
        name: cat['name'] as String? ?? 'Arma desconocida',
        upgradeLevel: (row['upgrade_level'] as num?)?.toInt() ?? 0,
        itemType: cat['item_type'] as String? ?? 'weapon',
      );
    }).where((w) => w.itemType == 'weapon').toList();
  }

  Future<Map<String, int>> loadMaterials(String characterId) async {
    final rows = await _client
        .from('inventory_items')
        .select('item_code,quantity')
        .eq('character_id', characterId)
        .inFilter('item_code', ['material_titanite_shard', 'material_large_titanite_shard', 'material_blackened_ember']);

    final out = <String, int>{};
    for (final row in rows) {
      out[row['item_code'] as String] = (row['quantity'] as num?)?.toInt() ?? 0;
    }
    return out;
  }

  Future<void> consumeMaterial(String characterId, String materialCode, int amount) async {
    final row = await _client
        .from('inventory_items')
        .select('id,quantity')
        .eq('character_id', characterId)
        .eq('item_code', materialCode)
        .single();
    final current = (row['quantity'] as num?)?.toInt() ?? 0;
    final next = current - amount;
    if (next <= 0) {
      await _client.from('inventory_items').delete().eq('id', row['id'] as String);
    } else {
      await _client.from('inventory_items').update({'quantity': next}).eq('id', row['id'] as String);
    }
  }

  Future<void> upgradeWeapon(String inventoryId, int nextLevel) async {
    await _client.from('inventory_items').update({'upgrade_level': nextLevel}).eq('id', inventoryId);
  }
}
