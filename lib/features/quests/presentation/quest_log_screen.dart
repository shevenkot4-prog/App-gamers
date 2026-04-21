import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../domain/quest_controller.dart';
import '../domain/quest_models.dart';

class QuestLogScreen extends ConsumerStatefulWidget {
  const QuestLogScreen({super.key});

  @override
  ConsumerState<QuestLogScreen> createState() => _QuestLogScreenState();
}

class _QuestLogScreenState extends ConsumerState<QuestLogScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(questControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questControllerProvider);

    return AshenScaffold(
      title: 'Registro de Quests',
      child: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)))
              : state.quests.isEmpty
                  ? const Center(child: Text('No hay quests para mostrar.'))
                  : ListView.separated(
                      itemCount: state.quests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => _QuestCard(quest: state.quests[index]),
                    ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest});

  final QuestStateModel quest;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quest.name ?? quest.questCode,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: quest.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(quest.description ?? 'Sin descripción.'),
            const SizedBox(height: 4),
            Text('Stage: ${quest.stage}'),
            Text('Estado final: ${quest.isCompleted ? 'Completada' : quest.isFailed ? 'Fallida' : 'En progreso'}'),
            if ((quest.reward ?? '').isNotEmpty) Text('Recompensa: ${quest.reward}'),
            if ((quest.notes ?? '').isNotEmpty) Text('Notas: ${quest.notes}'),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'completed':
        color = Colors.greenAccent;
        break;
      case 'failed':
        color = Colors.redAccent;
        break;
      case 'not_started':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.amberAccent;
        break;
    }
    return Chip(label: Text(status), backgroundColor: color.withOpacity(0.2));
  }
}
