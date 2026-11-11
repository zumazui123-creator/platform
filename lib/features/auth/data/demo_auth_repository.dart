import 'dart:async';

import '../domain/auth_models.dart';

/// Demo-Auth ohne Supabase.
///
/// Ohne Backend-Konfiguration startet die App direkt als "Demo-Nutzer"
/// (klar als Demo in der UI gekennzeichnet). Login/Signup simulieren
/// eine lokale Session — es wird kein echter Account angelegt und kein
/// Datenverkehr gesendet.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository()
    : _controller = StreamController<AuthStatus>.broadcast() {
    _user = AppUser(id: 'demo-user', name: 'Demo-Nutzer', email: null);
  }

  final StreamController<AuthStatus> _controller;
  AppUser? _user;

  static const AppUser _demoUser = AppUser(
    id: 'demo-user',
    name: 'Demo-Nutzer',
  );

  @override
  bool get isDemo => true;

  @override
  Stream<AuthStatus> get authState => _controller.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = _demoUser;
    _emit();
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _user = AppUser(
      id: 'demo-user',
      name: name.isEmpty ? _demoUser.name : name,
    );
    _emit();
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _emit();
  }

  /// Initial-Emission (wird beim Erstellen des Providers angestoßen).
  void emitInitial() {
    _user ??= _demoUser;
    _emit();
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(
      _user == null ? const AuthAnonymous() : Authenticated(_user!),
    );
  }

  void dispose() {
    _controller.close();
  }
}
