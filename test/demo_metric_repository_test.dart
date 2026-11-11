import 'package:flutter_test/flutter_test.dart';
import 'package:health_platform/core/domain/health_area.dart';
import 'package:health_platform/features/data/demo/demo_metric_repository.dart';
import 'package:health_platform/features/data/series_catalog.dart';

void main() {
  final repo = DemoMetricRepository();

  test('ist Demo-Quelle', () {
    expect(repo.isDemo, isTrue);
  });

  for (final area in HealthArea.values) {
    test(
      'seriesFor(${area.name}) liefert alle Katalog-Serien mit Daten',
      () async {
        final series = await repo.seriesFor(area);
        final catalogIds = kSeriesCatalog
            .where((d) => d.area == area)
            .map((d) => d.id)
            .toSet();
        expect(series.map((s) => s.id), containsAll(catalogIds));
        for (final s in series) {
          expect(s.points, isNotEmpty, reason: '${s.id} braucht Demo-Daten');
          expect(s.area, area);
          // Aufsteigend nach Datum.
          for (var i = 1; i < s.points.length; i++) {
            expect(s.points[i].date.isBefore(s.points[i - 1].date), isFalse);
          }
        }
      },
    );
  }

  test('series(id) findet die Serie über alle Bereiche', () async {
    final s = await repo.series('health-weight');
    expect(s, isNotNull);
    expect(s!.area, HealthArea.gesundheit);
    expect(s.name, 'Körpergewicht');
    expect(s.unit, 'kg');
  });

  test('series(unbekannt) → null', () async {
    expect(await repo.series('does-not-exist'), isNull);
  });
}
