/// Auth-Domänenmodelle (framework-frei, unit-testbar).
library;

/// Angemeldeter Benutzer (minimaler, app-relevanter Ausschnitt).
class AppUser {
  const AppUser({required this.id, required this.name, this.email});

  final String id;
  final String name;
  final String? email;
}

/// Auth-Zustand der App (sealed → exhaustive Patterns in UI/Router).
sealed class AuthStatus {
  const AuthStatus();
}

/// Session wird noch geladen (Init/Synchronisation).
final class AuthLoading extends AuthStatus {
  const AuthLoading();
}

/// Nicht angemeldet.
final class AuthAnonymous extends AuthStatus {
  const AuthAnonymous();
}

/// Angemeldet mit [user].
final class Authenticated extends AuthStatus {
  const Authenticated(this.user);

  final AppUser user;

  @override
  String toString() => 'Authenticated(${user.name})';
}

/// Interface für Auth-Anbieter.
///
/// Implementierungen:
/// - `SupabaseAuthRepository` (Produktion, Supabase Auth + RLS)
/// - `DemoAuthRepository` (ohne Konfiguration; Demo-Nutzer, klar gekennzeichnet)
abstract interface class AuthRepository {
  /// Stream des Auth-Zustands (emittiert initial + bei jeder Änderung).
  Stream<AuthStatus> get authState;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// True, wenn die Auth eine Demo-Quelle ist (UI kennzeichnet das).
  bool get isDemo;
}
