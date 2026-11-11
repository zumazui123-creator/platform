import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/domain/health_area.dart';
import '../../../core/domain/metric_series.dart';
import '../../../core/errors.dart' as errors;
import '../metric_repository.dart';
import '../series_catalog.dart';

/// Supabase-Datenquelle: liest Messpunkte aus `metric_points` und
/// kombiniert sie mit dem [SeriesCatalog].
///
/// Tabelle:
/// ```
/// metric_points(
///   id uuid pk default gen_random_uuid(),
///   user_id uuid not null references auth.users on delete cascade,
///   area text not null,
///   series_id text not null,
///   value double precision not null,
///   measured_at timestamptz not null,
///   created_at timestamptz not null default now(),
///   unique (user_id, series_id, measured_at)
/// )
/// ```
/// RLS: `user_id = auth.uid()` für SELECT/INSERT/UPDATE/DELETE.
class SupabaseMetricRepository implements MetricSeriesRepository {
  SupabaseMetricRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'metric_points';

  @override
  bool get isDemo => false;

  @override
  Future<List<MetricSeries>> seriesFor(HealthArea area) async {
    final uid = _requireUser();
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .eq('area', area.name)
        .order('measured_at', ascending: true)
        .limit(5000);
    return _toSeries(rows, area);
  }

  @override
  Future<MetricSeries?> series(String id) async {
    final def = _catalogDef(id);
    if (def == null) return null;
    final all = await seriesFor(def.area);
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  String _requireUser() {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw errors.AuthException(
        'Keine aktive Session — Daten sind geschützt.',
      );
    }
    return session.user.id;
  }

  static SeriesDef? _catalogDef(String id) {
    for (final def in kSeriesCatalog) {
      if (def.id == id) return def;
    }
    return null;
  }

  List<MetricSeries> _toSeries(List<dynamic> rows, HealthArea area) {
    final bySeries = <String, List<MetricPoint>>{};
    for (final row in rows) {
      if (row is! Map) continue;
      final sid = row['series_id'];
      final v = row['value'];
      final at = row['measured_at'];
      if (sid is! String || v is! num || at is! String) continue;
      final date = DateTime.tryParse(at);
      if (date == null) continue;
      bySeries
          .putIfAbsent(sid, () => <MetricPoint>[])
          .add(MetricPoint(date.toLocal(), v.toDouble()));
    }
    return [
      for (final def in kSeriesCatalog.where((d) => d.area == area))
        if (bySeries[def.id]?.isNotEmpty ?? false)
          MetricSeries(
            id: def.id,
            name: def.name,
            unit: def.unit,
            area: area,
            points: bySeries[def.id]!,
          ),
    ];
  }
}
