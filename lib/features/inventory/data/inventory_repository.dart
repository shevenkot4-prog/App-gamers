import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/inventory_models.dart';

class InventoryRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<InventoryItemWithCatalogData>> fetchCharacterInventory(String characterId) async {
    final rows = await _client
        .from('inventory_items')
        .select('id,item_id,quantity,upgrade_level,is_equipped,equipped_slot,items_catalog(id,name,type,rarity,lore,effect_json)')
        .eq('character_id', characterId)
        .order('created_at', ascending: true);

    return rows.map<InventoryItemWithCatalogData>((row) {
      final catalog = (row['items_catalog'] as Map<String, dynamic>? ?? {});
      return InventoryItemWithCatalogData(
        inventoryItemId: row['id'] as String,
        itemId: row['item_id'] as String,
        name: catalog['name'] as String? ?? 'Objeto desconocido',
        type: catalog['type'] as String? ?? 'unknown',
        rarity: catalog['rarity'] as String? ?? 'common',
        quantity: (row['quantity'] as num?)?.toInt() ?? 1,
        lore: catalog['lore'] as String? ?? 'Sin descripción.',
        isEquipped: row['is_equipped'] as bool? ?? false,
        upgradeLevel: (row['upgrade_level'] as num?)?.toInt(),
        equippedSlot: row['equipped_slot'] as String?,
        effectJson: catalog['effect_json'] as Map<String, dynamic>?,
      );
    }).toList();
  }
}
