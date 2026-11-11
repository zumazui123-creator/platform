import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../core/errors.dart';
import '../domain/auth_models.dart';

/// Supabase-Auth: Session-Stream → [AuthStatus].
///
/// Keine Secrets im Client — nur der anon-Key, der über Row Level
/// Security strikt auf den eigenen Benutzer eingeschränkt ist.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  bool get isDemo => false;

  @override
  Stream<AuthStatus> get authState => _client.auth.onAuthStateChange.map((e) {
    final user = e.session?.user;
    if (user == null) return const AuthAnonymous();
    return Authenticated(
      AppUser(
        id: user.id,
        name:
            (user.userMetadata?['name'] as String?) ??
            (user.email ?? 'Benutzer'),
        email: user.email,
      ),
    );
  });

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw AuthException(
        'Anmeldung fehlgeschlagen. Bitte Zugangsdaten prüfen.',
        e,
      );
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
    } catch (e) {
      throw AuthException('Registrierung fehlgeschlagen.', e);
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
