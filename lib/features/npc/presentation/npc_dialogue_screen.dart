import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../quests/domain/quest_controller.dart';
import '../domain/npc_controller.dart';

class NpcDialogueScreen extends ConsumerStatefulWidget {
  const NpcDialogueScreen({required this.npcId, super.key});

  final String npcId;

  @override
  ConsumerState<NpcDialogueScreen> createState() => _NpcDialogueScreenState();
}

class _NpcDialogueScreenState extends ConsumerState<NpcDialogueScreen> {
  bool _loading = true;
  String? _error;
  String? _name;
  String? _title;
  String? _intro;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadNpc);
  }

  Future<void> _loadNpc() async {
    try {
      final npc = await ref.read(npcControllerProvider.notifier).getNpc(widget.npcId);
      if (npc == null) {
        setState(() {
          _loading = false;
          _error = 'No se encontró el NPC.';
        });
        return;
      }
      await ref.read(questControllerProvider.notifier).touchNpcQuest(widget.npcId);
      await ref.read(questControllerProvider.notifier).load();
      setState(() {
        _loading = false;
        _name = npc.name;
        _title = npc.title;
        _intro = npc.introText;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Error cargando diálogo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questControllerProvider).quests;
    return AshenScaffold(
      title: 'Diálogo',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name ?? '', style: Theme.of(context).textTheme.headlineSmall),
                    if (_title != null) ...[
                      const SizedBox(height: 4),
                      Text(_title!, style: const TextStyle(color: Colors.white70)),
                    ],
                    const SizedBox(height: 20),
                    Text(_intro ?? ''),
                    const SizedBox(height: 16),
                    const Text('Estado de quests relevantes'),
                    ...quests
                        .where((q) => q.questCode == 'quest_sir_edric' || q.questCode == 'quest_guardian_relic')
                        .map((q) => Text('${q.name ?? q.questCode}: ${q.status} (stage ${q.stage})')),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
    );
  }
}
