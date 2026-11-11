import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/health_area.dart';
import '../../core/domain/metric_series.dart';
import '../../core/providers.dart';
import '../data/metric_repository.dart';
import 'demo/demo_metric_repository.dart';
import 'supabase/supabase_metric_repository.dart';

/// Provider für Messreihen (Repository-Wahl: Supabase/Demo).

/// Das aktive Repository (Supabase wenn konfiguriert, sonst Demo).
final metricRepositoryProvider = Provider<MetricSeriesRepository>((ref) {
  if (ref.watch(supabaseEnabledProvider)) {
    return SupabaseMetricRepository(ref.watch(supabaseClientProvider));
  }
  return DemoMetricRepository();
});

/// Serien eines Bereichs.
final seriesByAreaProvider =
    FutureProvider.family<List<MetricSeries>, HealthArea>(
      (ref, area) => ref.watch(metricRepositoryProvider).seriesFor(area),
    );

/// Eine Serie nach stabiler ID (referenziert von Baustein-Props).
final seriesByIdProvider = FutureProvider.family<MetricSeries?, String>(
  (ref, id) => ref.watch(metricRepositoryProvider).series(id),
);

/// Ist die Datenquelle eine Demo-Quelle (UI-Kennzeichnung)?
final isDemoDataProvider = Provider<bool>(
  (ref) => ref.watch(metricRepositoryProvider).isDemo,
);
