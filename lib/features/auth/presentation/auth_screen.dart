import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/ashen_scaffold.dart';
import '../../../shared/widgets/loading_error_view.dart';
import '../../character/domain/character_controller.dart';
import '../domain/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _registerMode = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final authNotifier = ref.read(authControllerProvider.notifier);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    bool success = false;
    if (_registerMode) {
      success = await authNotifier.register(email, password);
    } else {
      success = await authNotifier.login(email, password);
    }
    if (!success || !mounted) return;

    final character = await ref.read(characterControllerProvider.notifier).loadActiveCharacter();
    if (!mounted) return;

    if (character == null) {
      context.go('/character/class');
    } else {
      context.go('/hub');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AshenScaffold(
      title: _registerMode ? 'Registro' : 'Iniciar Sesión',
      child: LoadingErrorView(
        isLoading: authState.loading,
        error: authState.error,
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_registerMode ? 'Crear cuenta' : 'Entrar'),
            ),
            TextButton(
              onPressed: () => setState(() => _registerMode = !_registerMode),
              child: Text(_registerMode ? 'Ya tengo cuenta' : 'Crear cuenta nueva'),
            ),
          ],
        ),
      ),
    );
  }
}
