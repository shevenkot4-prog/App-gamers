import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';

class LootScreen extends StatelessWidget {
  const LootScreen({required this.nodeCode, super.key});

  final String nodeCode;

  @override
  Widget build(BuildContext context) {
    return AshenScaffold(
      title: 'Botín',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nodo: $nodeCode'),
          const SizedBox(height: 8),
          const Text('Pantalla de botín base. Integración completa llegará luego.'),
          const Spacer(),
          OutlinedButton(onPressed: () => context.go('/map'), child: const Text('Volver al mapa')),
        ],
      ),
    );
  }
}
