/// App-weite Exception-Hierarchie.
///
/// Alle Features werfen/leiten aus [AppException] ab, damit Presentation
/// einheitlich Fehler behandeln kann (Snackbars, Fehler-Zustände).
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  /// Menschenglesbarer Fehler (Deutsch, UI-fertig).
  final String message;

  /// Optionale Ursache (z. B. Netzwerk-Fehler).
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Validierungsfehler (z. B. Dashboard-Schema, Formulare, Tool-Parameter).
final class ValidationException extends AppException {
  const ValidationException(super.message, [super.cause]);
}

/// Auth-Fehler (Login, Session, Berechtigung).
final class AuthException extends AppException {
  const AuthException(super.message, [super.cause]);
}

/// Netzwerk-/API-Fehler.
final class NetworkException extends AppException {
  const NetworkException(super.message, [super.cause]);
}

/// Gesuchter Eintrag nicht gefunden (Layout, Datensatz, Tool).
final class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.cause]);
}
