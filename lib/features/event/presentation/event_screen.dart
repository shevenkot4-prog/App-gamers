import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({required this.nodeCode, super.key});

  final String nodeCode;

  @override
  Widget build(BuildContext context) {
    return AshenScaffold(
      title: 'Evento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nodo: $nodeCode'),
          const SizedBox(height: 8),
          const Text('Este evento será expandido en próximos bloques.'),
          const Spacer(),
          OutlinedButton(onPressed: () => context.go('/map'), child: const Text('Volver al mapa')),
        ],
      ),
    );
  }
}
