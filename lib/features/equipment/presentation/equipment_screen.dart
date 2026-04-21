import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../character/domain/character_controller.dart';
import '../../inventory/domain/inventory_controller.dart';

class EquipmentScreen extends ConsumerStatefulWidget {
  const EquipmentScreen({super.key});

  @override
  ConsumerState<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends ConsumerState<EquipmentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final character = ref.read(characterControllerProvider).character;
      if (character != null) {
        ref.read(inventoryControllerProvider.notifier).loadInventory(character.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final invState = ref.watch(inventoryControllerProvider);
    final equippedViews = ref.watch(equippedItemsProvider);

    return AshenScaffold(
      title: 'Equipo',
      child: invState.loading
          ? const Center(child: CircularProgressIndicator())
          : invState.error != null
              ? Center(child: Text(invState.error!, style: const TextStyle(color: Colors.redAccent)))
              : ListView(
                  children: equippedViews.map((slotView) {
                    return Card(
                      child: ListTile(
                        title: Text(_slotLabel(slotView.slot)),
                        subtitle: slotView.name == null
                            ? const Text('Sin equipar')
                            : Text('${slotView.name} · ${slotView.type}\n${slotView.effectSummary ?? ''}'),
                        isThreeLine: slotView.name != null,
                      ),
                    );
                  }).toList(),
                ),
    );
  }

  String _slotLabel(String slot) {
    switch (slot) {
      case 'weapon_main':
        return 'Arma principal';
      case 'weapon_off':
        return 'Arma secundaria';
      case 'catalyst':
        return 'Catalizador';
      case 'head':
        return 'Cabeza';
      case 'torso':
        return 'Torso';
      case 'arms':
        return 'Brazos';
      case 'legs':
        return 'Piernas';
      case 'ring_1':
        return 'Anillo 1';
      case 'ring_2':
        return 'Anillo 2';
      default:
        return slot;
    }
  }
}
