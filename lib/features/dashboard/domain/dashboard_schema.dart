import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/domain/health_area.dart';

part 'dashboard_schema.freezed.dart';

/// Unterstützte Baustein-Typen des UI-Baukastens.
///
/// Nur diese Typen sind in Layouts erlaubt — der Validator lehnt alles
/// andere ab. Es wird niemals Code aus Konfigurationen geladen; jeder
/// Typ wird client-seitig von [WidgetType] zu einem festen Builder
/// aufgelöst (siehe features/dashboard/presentation/widget_registry.dart).
enum WidgetType {
  /// Große einzelne Kennzahl (z. B. "Aktuelles Gewicht: 78,4 kg").
  metricCard,

  /// Kennzahl mit Trend-Vergleich (Delta zu Vorperiode).
  statCard,

  /// Liniendiagramm über die Zeit.
  lineChart,

  /// Balkendiagramm (z. B. wöchensummen).
  barChart,

  /// Kreisdiagramm (Verteilung).
  pieChart,

  /// Fortschrittsanzeige gegen ein Ziel.
  progress,

  /// Tabelle der letzten Messwerte.
  table;

  /// Anzeigename für den Editor.
  String get label => switch (this) {
    WidgetType.metricCard => 'Zahlenkarte',
    WidgetType.statCard => 'Statistik-Karte',
    WidgetType.lineChart => 'Liniendiagramm',
    WidgetType.barChart => 'Balkendiagramm',
    WidgetType.pieChart => 'Kreisdiagramm',
    WidgetType.progress => 'Fortschrittsanzeige',
    WidgetType.table => 'Tabelle',
  };
}

/// Raster-Position/-Größe eines Bausteins.
///
/// Das Dashboard ist ein 4-Spalten-Raster (bei breiten Screens; auf
/// schmalen Screens wird die Breite 1:1 skalieren). Größen sind in
/// Raster-Einheiten, nicht in Pixel — dadurch sind Layouts
/// plattformunabhängig gespeichert.
@freezed
abstract class WidgetSize with _$WidgetSize {
  const factory WidgetSize({
    /// Breite in Raster-Spalten (1–4).
    @Default(2) int cols,

    /// Höhe in Raster-Reihen (1–3).
    @Default(2) int rows,
  }) = _WidgetSize;
}

/// Ein einzelner konfigurierter Baustein in einem Dashboard-Layout.
///
/// [props] ist typenspezifisch und wird pro [WidgetType] validiert
/// (siehe DashboardValidator). Erlaubte, bekannte Keys pro Typ:
/// - alle Typen: `seriesId` (String), `title` (String)
/// - progress: `target` (double)
/// - table: `rows` (int, 1–20)
/// Unbekannte Keys werden verworfen (kein Ausführen, kein Ausführen
/// von Code — reine Datenkonfiguration).
@freezed
abstract class WidgetConfig with _$WidgetConfig {
  const WidgetConfig._();

  const factory WidgetConfig({
    /// Stabile ID (Client generiert; UUID-artig).
    required String id,

    /// Baustein-Typ.
    required WidgetType type,

    /// Position innerhalb des Layouts (0-basiert, eindeutig).
    required int index,

    /// Raster-Größe.
    required WidgetSize size,

    /// Typspezifische, validierte Eigenschaften.
    @Default({}) Map<String, Object?> props,
  }) = _WidgetConfig;

  /// Bequemer Zugriff: konfigurierte Series-ID (falls vorhanden).
  String? get seriesId =>
      props['seriesId'] is String ? props['seriesId'] as String : null;

  /// Bequemer Zugriff: Titel (falls vorhanden).
  String? get title =>
      props['title'] is String ? props['title'] as String : null;
}

/// Ein versioniertes Dashboard-Layout.
///
/// Wird als JSON gespeichert (lokal bzw. Supabase `dashboard_layouts`).
/// [schemaVersion] erlaubt Migrationen: Unbekannte Versionen werden
/// abgelehnt statt still gedeutet.
@freezed
abstract class DashboardLayout with _$DashboardLayout {
  const factory DashboardLayout({
    /// Schema-Version (aktuell 1).
    @Default(1) int schemaVersion,

    /// Stabile ID des Layouts.
    required String id,

    /// Anzeigename.
    required String name,

    /// Hauptbereich, dem das Layout zugeordnet ist.
    required HealthArea area,

    /// Bausteine in Darstellungsreihenfolge (index aufsteigend).
    @Default([]) List<WidgetConfig> widgets,
  }) = _DashboardLayout;
}

/// Aktuelle Schema-Version — zentral gepflegt.
const int kDashboardSchemaVersion = 1;
