class InventoryItemWithCatalogData {
  const InventoryItemWithCatalogData({
    required this.inventoryItemId,
    required this.itemId,
    required this.name,
    required this.type,
    required this.rarity,
    required this.quantity,
    required this.lore,
    required this.isEquipped,
    this.upgradeLevel,
    this.equippedSlot,
    this.effectJson,
  });

  final String inventoryItemId;
  final String itemId;
  final String name;
  final String type;
  final String rarity;
  final int quantity;
  final String lore;
  final bool isEquipped;
  final int? upgradeLevel;
  final String? equippedSlot;
  final Map<String, dynamic>? effectJson;
}

class EquippedItemView {
  const EquippedItemView({
    required this.slot,
    this.name,
    this.type,
    this.effectSummary,
    this.item,
  });

  final String slot;
  final String? name;
  final String? type;
  final String? effectSummary;
  final InventoryItemWithCatalogData? item;
}
