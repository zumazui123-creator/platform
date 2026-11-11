import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

import '../../../core/domain/metric_series.dart';

/// Konvertiert [MetricSeries] in fl_chart-Datenstrukturen.
///
/// Bewusst frei von Flutter-Widgets (nur FlSpot/PieChartSectionData
/// ohne Farbe), damit die Engine unit-testbar ist. Farben werden
/// presentation-seitig aus dem Theme abgeleitet (siehe ChartStyle).
class ChartEngine {
  const ChartEngine._();

  /// Liniendiagramm-Punkte für [series].
  static List<FlSpot> lineSpots(MetricSeries series) => [
    for (final p in series.points)
      FlSpot(p.date.millisecondsSinceEpoch.toDouble(), p.value),
  ];

  /// X-Achsen-Bereiche (min/max der Datumswerte) für Achsen-Labels.
  static (double, double) lineRange(MetricSeries series) {
    if (series.points.isEmpty) return (0, 1);
    return (
      series.points.first.date.millisecondsSinceEpoch.toDouble(),
      series.points.last.date.millisecondsSinceEpoch.toDouble(),
    );
  }

  /// Balkendiagramm: Wochen-Summen/Ø über die letzten [weeks] Wochen
  /// (aggregiert, damit Diagramme lesbar bleiben).
  static List<double> weeklyValues(
    MetricSeries series, {
    int weeks = 8,
    bool sum = true,
  }) {
    if (series.points.isEmpty) return const [];
    final end = series.points.last.date;
    final values = <double>[];
    for (var w = weeks - 1; w >= 0; w--) {
      final weekEnd = end.subtract(Duration(days: w * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      final pts = series.points
          .where((p) => !p.date.isBefore(weekStart) && !p.date.isAfter(weekEnd))
          .toList();
      if (pts.isEmpty) {
        values.add(0);
      } else if (sum) {
        values.add(pts.fold<double>(0, (a, p) => a + p.value));
      } else {
        values.add(pts.fold<double>(0, (a, p) => a + p.value) / pts.length);
      }
    }
    return values;
  }

  /// Balkendiagramm-Paare (index → wert) für BarChart.
  static List<({int index, double value})> barEntries(
    MetricSeries series, {
    int weeks = 8,
    bool sum = true,
  }) => [
    for (
      var i = 0;
      i < weeklyValues(series, weeks: weeks, sum: sum).length;
      i++
    )
      (index: i, value: weeklyValues(series, weeks: weeks, sum: sum)[i]),
  ];

  /// Kreisdiagramm-Anteile: Anteil jeder Woche am Gesamtsummenwert
  /// (oder, bei wenigen Punkten, pro Punkt). Rückgabe: Wert pro Slice.
  static List<double> pieSlices(MetricSeries series, {int maxSlices = 7}) {
    final pts = series.points;
    if (pts.isEmpty) return const [];
    if (pts.length <= maxSlices) {
      return [for (final p in pts) p.value];
    }
    // Auf maxSlices gleich große Zeit-Fenster aggregieren.
    final chunk = (pts.length / maxSlices).ceil();
    final out = <double>[];
    for (var i = 0; i < pts.length; i += chunk) {
      final part = pts.sublist(i, min(i + chunk, pts.length));
      out.add(part.fold<double>(0, (a, p) => a + p.value));
    }
    return out;
  }

  /// Gesamtsumme der Slice-Werte (für %-Anzeigen in der Legende).
  static double pieTotal(List<double> slices) =>
      slices.fold(0, (a, b) => a + b);

  /// Letzter Wert + Delta zum Wert [daysBefore] Tage zuvor.
  /// Gibt (letzter Wert, Delta) zurück; Delta null bei zu wenig Daten.
  static (double last, double? delta) lastAndDelta(
    MetricSeries series, {
    int daysBefore = 7,
  }) {
    final last = series.last ?? 0;
    final idx = series.points.length - 1 - daysBefore;
    if (idx < 0) return (last, null);
    return (last, last - series.points[idx].value);
  }
}
