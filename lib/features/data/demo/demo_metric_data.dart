import 'dart:math';

import '../../../core/domain/metric_series.dart';
import '../series_catalog.dart';

/// Deterministische Demo-Punkterzeugung.
///
/// Ohne Supabase-Konfiguration macht die App damit weiterhin einen
/// vollständigen Eindruck (klar als Demo erkennbar); in Tests liefert
/// sie stabile, seeded Daten. Gleiche Serie-ID → gleiche Punkte.
class DemoMetricData {
  const DemoMetricData._();

  /// Erzeugt die Demo-Punkte einer [def] (60–90 Tage je Serie).
  static List<MetricPoint> pointsFor(SeriesDef def, {DateTime? now}) {
    final p = _params[def.id];
    if (p == null) return const [];
    final rng = _Lcg(seed: _hash(def.id));
    final now_ = (now ?? DateTime(2026, 11, 10)).toLocal();
    final points = <MetricPoint>[];
    for (var d = p.days - 1; d >= 0; d--) {
      final date = now_.subtract(Duration(days: d));
      final t = p.days - 1 - d;
      var v =
          p.base +
          p.trend * t +
          p.amplitude * sin(2 * pi * t / 28) * rng.nextDouble() +
          (rng.nextDouble() * 2 - 1) * p.noise;
      if (p.weeklyCycle) {
        final dow = date.weekday;
        v += (dow == 6 || dow == 7) ? p.amplitude * 0.35 : 0;
      }
      if (p.clamp != null) v = p.clamp!(v);
      v = double.parse(v.toStringAsFixed(p.decimals));
      points.add(MetricPoint(date, v));
    }
    return points;
  }

  /// Vollständige Demo-Serie (Katalog + Punkte).
  static MetricSeries series(SeriesDef def, {DateTime? now}) => MetricSeries(
    id: def.id,
    name: def.name,
    unit: def.unit,
    area: def.area,
    points: pointsFor(def, now: now),
  );
}

/// Erzeugungsparameter einer Demo-Serie.
class _Param {
  const _Param({
    required this.days,
    required this.base,
    required this.amplitude,
    required this.trend,
    required this.noise,
    this.weeklyCycle = false,
    this.clamp,
    required this.decimals,
  });

  final int days;
  final double base;
  final double amplitude;
  final double trend;
  final double noise;
  final bool weeklyCycle;
  final double Function(double)? clamp;
  final int decimals;
}

final Map<String, _Param> _params = {
  'health-weight': _Param(
    days: 90,
    base: 81.0,
    amplitude: 2.2,
    trend: -0.012,
    noise: 0.35,
    decimals: 1,
  ),
  'health-systolic': _Param(
    days: 60,
    base: 128,
    amplitude: 9,
    trend: -0.02,
    noise: 3.5,
    decimals: 0,
  ),
  'health-glucose': _Param(
    days: 60,
    base: 96,
    amplitude: 8,
    trend: 0.01,
    noise: 4,
    decimals: 0,
  ),
  'health-resting-hr': _Param(
    days: 90,
    base: 62,
    amplitude: 4,
    trend: -0.01,
    noise: 1.6,
    decimals: 0,
  ),
  'fitness-steps': _Param(
    days: 90,
    base: 8200,
    amplitude: 2600,
    trend: 6,
    noise: 1400,
    weeklyCycle: true,
    decimals: 0,
  ),
  'fitness-calories': _Param(
    days: 90,
    base: 2750,
    amplitude: 420,
    trend: 3,
    noise: 260,
    weeklyCycle: true,
    decimals: 0,
  ),
  'fitness-workout-min': _Param(
    days: 90,
    base: 42,
    amplitude: 26,
    trend: 0.2,
    noise: 12,
    weeklyCycle: true,
    decimals: 0,
  ),
  'fitness-vo2max': _Param(
    days: 60,
    base: 38.5,
    amplitude: 0.8,
    trend: 0.012,
    noise: 0.3,
    decimals: 1,
  ),
  'psych-mood': _Param(
    days: 90,
    base: 6.4,
    amplitude: 1.4,
    trend: 0.004,
    noise: 0.7,
    weeklyCycle: true,
    clamp: (v) => v.clamp(1, 10),
    decimals: 1,
  ),
  'psych-stress': _Param(
    days: 90,
    base: 5.2,
    amplitude: 1.6,
    trend: -0.005,
    noise: 0.8,
    weeklyCycle: true,
    clamp: (v) => v.clamp(1, 10),
    decimals: 1,
  ),
  'psych-sleep-h': _Param(
    days: 90,
    base: 7.1,
    amplitude: 0.9,
    trend: 0.002,
    noise: 0.5,
    decimals: 1,
  ),
  'psych-sleep-quality': _Param(
    days: 90,
    base: 6.8,
    amplitude: 1.1,
    trend: 0.003,
    noise: 0.6,
    clamp: (v) => v.clamp(1, 10),
    decimals: 1,
  ),
};

int _hash(String s) {
  var h = 2166136261;
  for (final unit in s.codeUnits) {
    h ^= unit;
    h = (h * 16777619) & 0xFFFFFFFF;
  }
  return h & 0x7FFFFFFF;
}

/// Kleiner, deterministischer Linear Congruential Generator (Numerical
/// Recipes). Nicht kryptografisch — nur für stabile Demo-/Testdaten.
class _Lcg {
  _Lcg({required int seed}) : _state = seed & 0xFFFFFFFF;

  int _state;

  int _nextInt() {
    _state = (_state * 1664525 + 1013904223) & 0xFFFFFFFF;
    return _state;
  }

  double nextDouble() => _nextInt() / 0x100000000;
}
