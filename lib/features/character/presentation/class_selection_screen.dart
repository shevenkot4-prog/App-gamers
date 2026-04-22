import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../domain/character_class.dart';

class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = CharacterClass.values;

    return AshenScaffold(
      title: 'Selección de Clase',
      child: ListView(
        children: classes
            .map(
              (characterClass) => _ClassCard(
                classOption: characterClass,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classOption});

  final CharacterClass classOption;

  @override
  Widget build(BuildContext context) {
    final title = classOption.displayName;
    final description = switch (classOption) {
      CharacterClass.knight => 'Baluarte de acero; vida alta y defensa sólida.',
      CharacterClass.vagabond => 'Errante veloz; más destreza y equipo ligero.',
      CharacterClass.sorcerer => 'Discípulo arcano; menor vida, magia inicial.',
    };
    final styleText = switch (classOption) {
      CharacterClass.knight => 'Equilibrado, ideal para frente de batalla.',
      CharacterClass.vagabond => 'Movilidad alta y esquivas agresivas.',
      CharacterClass.sorcerer => 'Control de distancia y daño mágico.',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 6),
            Text(styleText),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go(
                '/character/name?classCode=${classOption.dbValue}&className=${classOption.displayName}',
              ),
              child: const Text('Seleccionar'),
            ),
          ],
        ),
      ),
    );
  }
}
