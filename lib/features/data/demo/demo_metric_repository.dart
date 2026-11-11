import '../../../core/domain/health_area.dart';
import '../../../core/domain/metric_series.dart';
import 'demo_metric_data.dart';
import '../metric_repository.dart';
import '../series_catalog.dart';

/// Repository mit deterministischen Demo-Daten (kein Netzwerk, kein
/// Supabase). Die App bleibt damit ohne Konfiguration voll nutzbar —
/// in der UI als "Demo-Daten" gekennzeichnet.
class DemoMetricRepository implements MetricSeriesRepository {
  const DemoMetricRepository();

  @override
  bool get isDemo => true;

  @override
  Future<List<MetricSeries>> seriesFor(HealthArea area) async => [
    for (final def in kSeriesCatalog.where((d) => d.area == area))
      DemoMetricData.series(def),
  ];

  @override
  Future<MetricSeries?> series(String id) async {
    final def = kSeriesCatalog
        .where((d) => d.id == id)
        .cast<SeriesDef?>()
        .firstWhere((d) => d != null, orElse: () => null);
    if (def == null) return null;
    return DemoMetricData.series(def);
  }
}
