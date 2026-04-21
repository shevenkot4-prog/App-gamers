import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

class AuthUiState {
  const AuthUiState({this.loading = false, this.error});

  final bool loading;
  final String? error;

  AuthUiState copyWith({bool? loading, String? error}) {
    return AuthUiState(
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthUiState> {
  AuthController(this._repository) : super(const AuthUiState());

  final AuthRepository _repository;

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repository.signIn(email: email, password: password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _readableError(e));
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repository.signUp(email: email, password: password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _readableError(e));
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repository.signOut();
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: _readableError(e));
    }
  }

  String _readableError(Object e) {
    final raw = e.toString();
    if (raw.contains('Invalid login credentials')) {
      return 'Credenciales inválidas.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }
    return 'Error de autenticación: $raw';
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthUiState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
