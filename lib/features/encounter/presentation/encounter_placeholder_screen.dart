import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';

class EncounterPlaceholderScreen extends StatelessWidget {
  const EncounterPlaceholderScreen({required this.nodeCode, super.key});

  final String nodeCode;

  @override
  Widget build(BuildContext context) {
    return AshenScaffold(
      title: 'Encuentro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nodo de combate: $nodeCode'),
          const SizedBox(height: 8),
          const Text('EncounterScreen listo como transición para Bloque 5.'),
          const Spacer(),
          OutlinedButton(onPressed: () => context.go('/map'), child: const Text('Volver al mapa')),
        ],
      ),
    );
  }
}
