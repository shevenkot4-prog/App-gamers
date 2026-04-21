import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../../shared/widgets/loading_error_view.dart';
import '../domain/character_controller.dart';

class CharacterNamingScreen extends ConsumerStatefulWidget {
  const CharacterNamingScreen({required this.selectedClass, super.key});

  final String selectedClass;

  @override
  ConsumerState<CharacterNamingScreen> createState() => _CharacterNamingScreenState();
}

class _CharacterNamingScreenState extends ConsumerState<CharacterNamingScreen> {
  final _nameCtrl = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool _validateName() {
    final value = _nameCtrl.text.trim();
    if (value.length < 3) {
      setState(() => _validationError = 'El nombre debe tener al menos 3 caracteres.');
      return false;
    }
    if (value.length > 18) {
      setState(() => _validationError = 'El nombre no puede superar 18 caracteres.');
      return false;
    }
    setState(() => _validationError = null);
    return true;
  }

  Future<void> _createCharacter() async {
    if (!_validateName()) return;

    final character = await ref.read(characterControllerProvider.notifier).createCharacter(
          name: _nameCtrl.text.trim(),
          className: widget.selectedClass,
        );

    if (character != null && mounted) {
      context.go('/hub');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterControllerProvider);

    return AshenScaffold(
      title: 'Nombre del Personaje',
      child: LoadingErrorView(
        isLoading: state.loading,
        error: state.error,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clase elegida: ${widget.selectedClass}'),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              maxLength: 18,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_validationError!, style: const TextStyle(color: Colors.redAccent)),
              ),
            ElevatedButton(
              onPressed: _createCharacter,
              child: const Text('Crear personaje'),
            ),
          ],
        ),
      ),
    );
  }
}
