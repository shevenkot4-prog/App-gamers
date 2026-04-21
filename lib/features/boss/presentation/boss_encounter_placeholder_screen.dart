import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';

class BossEncounterPlaceholderScreen extends StatelessWidget {
  const BossEncounterPlaceholderScreen({required this.nodeCode, super.key});

  final String nodeCode;

  @override
  Widget build(BuildContext context) {
    return AshenScaffold(
      title: 'Jefe',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nodo de jefe: $nodeCode'),
          const SizedBox(height: 8),
          const Text('Transición a combate de jefe preparada para Bloque 5.'),
          const Spacer(),
          OutlinedButton(onPressed: () => context.go('/map'), child: const Text('Volver al mapa')),
        ],
      ),
    );
  }
}
