import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../domain/encounter_controller.dart';

class EncounterScreen extends ConsumerStatefulWidget {
  const EncounterScreen({required this.nodeCode, super.key});

  final String nodeCode;

  @override
  ConsumerState<EncounterScreen> createState() => _EncounterScreenState();
}

class _EncounterScreenState extends ConsumerState<EncounterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(encounterControllerProvider.notifier).loadEncounter(widget.nodeCode));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(encounterControllerProvider);
    final encounter = state.encounter;

    return AshenScaffold(
      title: 'Encuentro',
      child: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)))
              : encounter == null
                  ? const Center(child: Text('No hay encuentro en este nodo.'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          encounter.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: encounter.isBoss ? Colors.redAccent : null,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(encounter.description),
                        const SizedBox(height: 8),
                        Text(encounter.isBoss ? 'Encuentro de Jefe' : 'Encuentro Hostil'),
                        Text('Daño enemigo estimado: ${encounter.damageMin}-${encounter.damageMax}'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => context.go('/combat?node=${widget.nodeCode}'),
                          child: const Text('Luchar'),
                        ),
                        if (!encounter.isBoss)
                          OutlinedButton(
                            onPressed: () => context.go('/map'),
                            child: const Text('Retirarse'),
                          ),
                      ],
                    ),
    );
  }
}
