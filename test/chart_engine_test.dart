import 'package:flutter_test/flutter_test.dart';
import 'package:health_platform/core/domain/health_area.dart';
import 'package:health_platform/core/domain/metric_series.dart';
import 'package:health_platform/features/charts/domain/chart_engine.dart';

MetricSeries series({required List<double> values, DateTime? start}) {
  final s = start ?? DateTime(2026, 1, 5);
  return MetricSeries(
    id: 'test',
    name: 'Test',
    unit: 'u',
    area: HealthArea.fitness,
    points: [
      for (var i = 0; i < values.length; i++)
        MetricPoint(s.add(Duration(days: i)), values[i]),
    ],
  );
}

void main() {
  group('lineSpots / lineRange', () {
    test('Spots spiegeln die Punkte', () {
      final s = series(values: [1, 3, 2]);
      final spots = ChartEngine.lineSpots(s);
      expect(spots.length, 3);
      expect(spots[1].y, 3);
      final range = ChartEngine.lineRange(s);
      expect(range.$1, spots.first.x);
      expect(range.$2, spots.last.x);
    });

    test('leere Serie → sicherer Range (0,1)', () {
      final s = series(values: []);
      expect(ChartEngine.lineSpots(s), isEmpty);
      expect(ChartEngine.lineRange(s), (0, 1));
    });
  });

  group('weeklyValues', () {
    test('aggregiert 8 Wochen (Summe), letzte Woche korrekt', () {
      // 8 Tage Daten ab 1.1.2026. Letzte Woche = 2.1.–8.1. (7 Punkte),
      // Woche davor = 1.1. (1 Punkt) — Wochenende ist der letzte Datentag.
      final s = series(
        start: DateTime(2026, 1, 1),
        values: [1, 1, 1, 1, 1, 1, 1, 1],
      );
      final weeks = ChartEngine.weeklyValues(s, weeks: 8, sum: true);
      expect(weeks.length, 8);
      expect(weeks, [0, 0, 0, 0, 0, 0, 1, 7]);
    });

    test('Ø-Modus teilt durch Anzahl der Punkte', () {
      final s = series(start: DateTime(2026, 1, 1), values: [2, 4]);
      final weeks = ChartEngine.weeklyValues(s, weeks: 2, sum: false);
      expect(weeks.last, 3); // (2+4)/2
    });

    test('leere Serie → leere Liste', () {
      expect(ChartEngine.weeklyValues(series(values: [])), isEmpty);
    });
  });

  group('pieSlices / pieTotal', () {
    test('wenige Punkte → je ein Slice', () {
      final s = series(values: [1, 2, 3]);
      expect(ChartEngine.pieSlices(s, maxSlices: 7), [1, 2, 3]);
      expect(ChartEngine.pieTotal([1, 2, 3]), 6);
    });

    test('viele Punkte → Aggregation auf maxSlices', () {
      final s = series(values: List.generate(10, (i) => 1.0));
      final slices = ChartEngine.pieSlices(s, maxSlices: 4);
      expect(slices.length, 4);
      expect(slices.fold(0.0, (a, b) => a + b), 10);
    });

    test('leere Serie → leere Slices, Summe 0', () {
      expect(ChartEngine.pieSlices(series(values: [])), isEmpty);
      expect(ChartEngine.pieTotal(const []), 0);
    });
  });

  group('lastAndDelta', () {
    test('zu wenig Daten → Delta null', () {
      final (last, delta) = ChartEngine.lastAndDelta(series(values: [5, 6]));
      expect(last, 6);
      expect(delta, isNull);
    });

    test('Delta zum Wert 7 Tage zuvor', () {
      // Tag 0..9: Werte 1..10 → Letzter = 10, Tag 2 = 3 → Delta 7.
      final s = series(values: List.generate(10, (i) => i + 1.0));
      final (last, delta) = ChartEngine.lastAndDelta(s, daysBefore: 7);
      expect(last, 10);
      expect(delta, 7);
    });
  });
}
