import 'health_area.dart';

/// Ein einzelner Messpunkt.
class MetricPoint {
  const MetricPoint(this.date, this.value);

  /// Messzeitpunkt.
  final DateTime date;

  /// Messwert.
  final double value;

  @override
  bool operator ==(Object other) =>
      other is MetricPoint && other.date == date && other.value == value;

  @override
  int get hashCode => Object.hash(date, value);
}

/// Eine benannte, dimensionierte Zeitreihe (z. B. "Blutdruck systolisch",
/// Einheit `mmHg`, Bereich Gesundheit).
class MetricSeries {
  const MetricSeries({
    required this.id,
    required this.name,
    required this.unit,
    required this.area,
    required this.points,
  });

  /// Eindeutige ID, auf die Dashboard-Bausteine per `props['seriesId']`
  /// verweisen (stabil über Sessions, keine Index-Zeiger).
  final String id;

  /// Anzeigename.
  final String name;

  /// Mengeneinheit (z. B. `kg`, `mmHg`, `min`, `1–10`).
  final String unit;

  /// Zugehöriger Hauptbereich.
  final HealthArea area;

  /// Messpunkte, aufsteigend nach Datum.
  final List<MetricPoint> points;

  double get min => _extreme(false);

  double get max => _extreme(true);

  double get average {
    if (points.isEmpty) return 0;
    final sum = points.fold<double>(0, (acc, p) => acc + p.value);
    return sum / points.length;
  }

  /// Letzter Messwert (oder null bei leerer Reihe).
  double? get last => points.isEmpty ? null : points.last.value;

  double _extreme(bool max) {
    var e = points.first.value;
    for (final p in points.skip(1)) {
      if (max ? p.value > e : p.value < e) e = p.value;
    }
    return e;
  }
}
