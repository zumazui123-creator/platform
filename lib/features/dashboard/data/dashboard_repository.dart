import '../domain/dashboard_schema.dart';

/// Persistenz für Dashboard-Layouts.
///
/// Implementierungen:
/// - [LocalDashboardRepository] (Demo/Betrieb ohne Supabase;
///   shared_preferences, seeded mit Beispiel-Layouts)
/// - `SupabaseDashboardRepository` (Produktion; Tabelle
///   `dashboard_layouts`, RLS-geschützt)
abstract interface class DashboardRepository {
  /// Alle Layouts (alle Bereiche).
  Future<List<DashboardLayout>> listAll();

  /// Einzelnes Layout nach ID.
  Future<DashboardLayout?> load(String id);

  /// Legt ein Layout an oder aktualisiert es (Upsert).
  /// Die [layout] muss valide sein (DashboardValidator).
  Future<void> save(DashboardLayout layout);

  /// Löscht ein Layout nach ID.
  Future<void> delete(String id);

  /// True, wenn die Quelle keine echte Benutzerdaten-Persistenz ist.
  bool get isDemo;
}
