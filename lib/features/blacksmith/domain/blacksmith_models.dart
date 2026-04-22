class UpgradeableWeaponView {
  const UpgradeableWeaponView({
    required this.inventoryId,
    required this.itemCode,
    required this.name,
    required this.upgradeLevel,
    required this.itemType,
  });

  final String inventoryId;
  final String itemCode;
  final String name;
  final int upgradeLevel;
  final String itemType;
}

class UpgradeRequirement {
  const UpgradeRequirement({
    required this.materialCode,
    required this.materialName,
    required this.quantity,
    required this.hasEnough,
    required this.emberRequired,
    required this.emberUnlocked,
  });

  final String materialCode;
  final String materialName;
  final int quantity;
  final bool hasEnough;
  final bool emberRequired;
  final bool emberUnlocked;
}
