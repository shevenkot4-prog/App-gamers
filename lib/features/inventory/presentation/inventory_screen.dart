import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../character/domain/character_controller.dart';
import '../domain/inventory_controller.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
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
    final state = ref.watch(inventoryControllerProvider);

    return AshenScaffold(
      title: 'Inventario',
      child: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)))
              : state.items.isEmpty
                  ? const Center(child: Text('No llevas objetos en este momento.'))
                  : ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Card(
                          child: ExpansionTile(
                            title: Text(item.name),
                            subtitle: Text('${item.type} · ${item.rarity} · x${item.quantity}${item.isEquipped ? ' · Equipado' : ''}'),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            children: [
                              if (item.upgradeLevel != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Nivel de mejora: +${item.upgradeLevel}'),
                                ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(item.lore),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
