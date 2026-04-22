import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../domain/combat_controller.dart';
import '../domain/combat_models.dart';

class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({required this.nodeCode, super.key});

  final String nodeCode;

  @override
  ConsumerState<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends ConsumerState<CombatScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(combatControllerProvider.notifier).start(widget.nodeCode));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(combatControllerProvider);

    if (state.finished && state.playerWon) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/map');
      });
    }

    if (state.finished && state.playerLost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/death');
      });
    }

    return AshenScaffold(
      title: 'Combate Táctico',
      child: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.encounter?.name ?? 'Enemigo', style: Theme.of(context).textTheme.titleLarge),
                    Text('Intención enemiga: ${state.intent?.label ?? '-'}'),
                    const SizedBox(height: 10),
                    Text('Jugador HP: ${state.player?.hp}/${state.player?.maxHp}'),
                    Text('Jugador Aguante: ${state.player?.stamina}/${state.player?.maxStamina}'),
                    Text('Estus: ${state.player?.estus}/${state.player?.estusMax}'),
                    const SizedBox(height: 8),
                    Text('Enemigo HP: ${state.enemy?.hp}/${state.enemy?.maxHp}'),
                    const SizedBox(height: 8),
                    if (state.roundResult != null)
                      Text(
                        state.roundResult!.summary,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ActionBtn(label: 'Ataque ligero', disabled: state.actionInProgress, onTap: () => _act(CombatAction.lightAttack)),
                        _ActionBtn(label: 'Ataque fuerte', disabled: state.actionInProgress, onTap: () => _act(CombatAction.heavyAttack)),
                        _ActionBtn(label: 'Esquivar', disabled: state.actionInProgress, onTap: () => _act(CombatAction.dodge)),
                        _ActionBtn(label: 'Bloquear', disabled: state.actionInProgress, onTap: () => _act(CombatAction.block)),
                        _ActionBtn(label: 'Usar Estus', disabled: state.actionInProgress, onTap: () => _act(CombatAction.useEstus)),
                        _ActionBtn(label: 'Hechizo', disabled: state.actionInProgress, onTap: () => _act(CombatAction.castSpell)),
                      ],
                    ),
                  ],
                ),
    );
  }

  void _act(CombatAction action) {
    ref.read(combatControllerProvider.notifier).act(action);
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.onTap, this.disabled = false});
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 160, child: ElevatedButton(onPressed: disabled ? null : onTap, child: Text(label)));
  }
}
