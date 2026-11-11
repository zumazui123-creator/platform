/// Runtime-Konfiguration über `--dart-define`.
///
/// Nur öffentliche, nicht-geheime Werte gehören in den Client:
/// Supabase-URL + anon-Key (RLS schützt die Daten) sowie AI-Einstellungen.
/// Service-Role-Keys und API-Keys gehören ausschließlich auf dem Server
/// (Supabase Edge Functions / Secrets), nie in diesen Client.
///
/// Beispiele:
/// ```
/// flutter run -d chrome \
///   --dart-define=HEALTH_SUPABASE_URL=https://xyz.supabase.co \
///   --dart-define=HEALTH_SUPABASE_ANON_KEY=eyJ...
/// ```
class Env {
  const Env._();

  /// Basis-URL des Supabase-Projekts.
  static const String supabaseUrl = String.fromEnvironment(
    'HEALTH_SUPABASE_URL',
  );

  /// Supabase anon (public) Key — sicherheitshalber RLS-pflichtig.
  static const String supabaseAnonKey = String.fromEnvironment(
    'HEALTH_SUPABASE_ANON_KEY',
  );

  /// AI-Betriebsmodus: `demo` (ohne KI-Anbindung, klar gekennzeichnet),
  /// `edge` (über Supabase Edge Function `ai-gateway` — empfohlen) oder
  /// `direct` (OpenAI-kompatibler Endpunkt, nur für Entwicklung!).
  static const String aiMode = String.fromEnvironment(
    'HEALTH_AI_MODE',
    defaultValue: 'demo',
  );

  /// Basis-URL für `direct`-Modus (OpenAI-kompatible /chat/completions API).
  static const String aiBaseUrl = String.fromEnvironment(
    'HEALTH_AI_BASE_URL',
    defaultValue: 'https://api.openai.com/v1',
  );

  /// API-Key für den `direct`-Modus. Nur Entwicklung/lokale Endpunkte!
  /// Für Produktion immer `edge` verwenden.
  static const String aiApiKey = String.fromEnvironment('HEALTH_AI_API_KEY');

  /// Modell-Name für den `direct`-Modus.
  static const String aiModel = String.fromEnvironment(
    'HEALTH_AI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );

  /// Ist ein Supabase-Projekt konfiguriert?
  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('http') && supabaseAnonKey.isNotEmpty;

  /// AI läuft über die abgesicherte Edge Function.
  static bool get isEdgeAi => aiMode == 'edge' && isSupabaseConfigured;

  /// AI läuft direkt gegen einen OpenAI-kompatiblen Endpunkt (Dev nur).
  static bool get isDirectAi => aiMode == 'direct' && aiApiKey.isNotEmpty;

  /// Kein AI-Modus verfügbar → Demo-Modus (klar gekennzeichnet).
  static bool get isDemoAi => !isEdgeAi && !isDirectAi;
}
