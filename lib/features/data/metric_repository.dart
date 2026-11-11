import '../../core/domain/health_area.dart';
import '../../core/domain/metric_series.dart';

/// Datenquelle für Messreihen.
///
/// Zwei Implementierungen:
/// - [DemoMetricRepository] (ohne Supabase; deterministische Demo-Daten)
/// - `SupabaseMetricRepository` (Produktion; Tabelle `metric_points`)
///
/// Die Wahl erfolgt zentral über `metricRepositoryProvider` (Riverpod).
abstract interface class MetricSeriesRepository {
  /// Alle Serien eines Bereichs (mit Punkten), aufsteigend nach Datum.
  Future<List<MetricSeries>> seriesFor(HealthArea area);

  /// Eine Serie nach stabiler ID (über alle Bereiche).
  Future<MetricSeries?> series(String id);

  /// True, wenn die Quelle aus Demo-Daten besteht (UI kennzeichnet das).
  bool get isDemo;
}
