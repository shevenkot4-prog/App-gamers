import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../character/domain/character_controller.dart';
import '../data/inventory_repository.dart';
import 'inventory_models.dart';

class InventoryState {
  const InventoryState({this.loading = false, this.error, this.items = const []});

  final bool loading;
  final String? error;
  final List<InventoryItemWithCatalogData> items;

  InventoryState copyWith({bool? loading, String? error, List<InventoryItemWithCatalogData>? items}) {
    return InventoryState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
    );
  }
}

class InventoryController extends StateNotifier<InventoryState> {
  InventoryController(this._repository) : super(const InventoryState());

  final InventoryRepository _repository;

  Future<void> loadInventory(String characterId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await _repository.fetchCharacterInventory(characterId);
      state = state.copyWith(loading: false, items: items);
    } catch (e) {
      state = state.copyWith(loading: false, error: 'No se pudo cargar inventario: $e');
    }
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository();
});

final inventoryControllerProvider = StateNotifierProvider<InventoryController, InventoryState>((ref) {
  return InventoryController(ref.watch(inventoryRepositoryProvider));
});

final equippedItemsProvider = Provider<List<EquippedItemView>>((ref) {
  final items = ref.watch(inventoryControllerProvider).items;
  const slots = [
    'weapon_main',
    'weapon_off',
    'catalyst',
    'head',
    'torso',
    'arms',
    'legs',
    'ring_1',
    'ring_2',
  ];

  return slots.map((slot) {
    InventoryItemWithCatalogData? equipped;
    for (final item in items) {
      if (item.isEquipped && item.equippedSlot == slot) {
        equipped = item;
        break;
      }
    }

    if (equipped == null) return EquippedItemView(slot: slot);

    return EquippedItemView(
      slot: slot,
      name: equipped.name,
      type: equipped.type,
      effectSummary: _effectSummary(equipped.effectJson),
      item: equipped,
    );
  }).toList();
});

String _effectSummary(Map<String, dynamic>? effectJson) {
  if (effectJson == null || effectJson.isEmpty) return 'Sin bonus visible';
  final firstEntry = effectJson.entries.first;
  return '${firstEntry.key}: ${firstEntry.value}';
}

final ensureInventoryLoadedProvider = FutureProvider<void>((ref) async {
  final character = ref.watch(characterControllerProvider).character;
  if (character == null) return;
  await ref.read(inventoryControllerProvider.notifier).loadInventory(character.id);
});
