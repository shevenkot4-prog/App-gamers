import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';

class ClassSelectionScreen extends StatelessWidget {
  const ClassSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AshenScaffold(
      title: 'Selección de Clase',
      child: ListView(
        children: const [
          _ClassCard(
            title: 'Caballero',
            description: 'Baluarte de acero; vida alta y defensa sólida.',
            styleText: 'Equilibrado, ideal para frente de batalla.',
          ),
          _ClassCard(
            title: 'Vagabundo',
            description: 'Errante veloz; más destreza y equipo ligero.',
            styleText: 'Movilidad alta y esquivas agresivas.',
          ),
          _ClassCard(
            title: 'Hechicero',
            description: 'Discípulo arcano; menor vida, magia inicial.',
            styleText: 'Control de distancia y daño mágico.',
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.title, required this.description, required this.styleText});

  final String title;
  final String description;
  final String styleText;

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => context.go('/character/name?class=$title'),
              child: const Text('Seleccionar'),
            ),
          ],
        ),
      ),
    );
  }
}
