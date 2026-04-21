import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
