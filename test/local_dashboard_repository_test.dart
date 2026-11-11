import 'package:flutter_test/flutter_test.dart';
import 'package:health_platform/core/domain/health_area.dart';
import 'package:health_platform/core/errors.dart';
import 'package:health_platform/features/dashboard/data/local_dashboard_repository.dart';
import 'package:health_platform/features/dashboard/domain/dashboard_schema.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late LocalDashboardRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = LocalDashboardRepository(prefs);
  });

  DashboardLayout custom({
    String id = 'custom-1',
    HealthArea area = HealthArea.fitness,
  }) => DashboardLayout(
    id: id,
    name: 'Mein eigenes Layout',
    area: area,
    widgets: [
      WidgetConfig(
        id: 'cw1',
        type: WidgetType.statCard,
        index: 0,
        size: const WidgetSize(cols: 1, rows: 1),
        props: const {'seriesId': 'fitness-steps'},
      ),
    ],
  );

  test('ist Demo-Quelle', () {
    expect(repo.isDemo, isTrue);
  });

  test('seedet Standard-Layouts beim ersten Start', () async {
    final all = await repo.listAll();
    expect(all, isNotEmpty);
    final areas = all.map((l) => l.area).toSet();
    expect(areas, containsAll(HealthArea.values));
    // Jedes geseedete Layout hat mindestens einen Baustein.
    for (final l in all) {
      expect(l.widgets, isNotEmpty, reason: '${l.id} sollte Bausteine haben');
    }
  });

  test('gepeicherte Layouts überleben Reload', () async {
    final layout = custom();
    await repo.save(layout);

    final all = await repo.listAll();
    final found = all.where((l) => l.id == 'custom-1').toList();
    expect(found, hasLength(1));
    expect(found.first.widgets.single.type, WidgetType.statCard);
    expect(found.first.widgets.single.props['seriesId'], 'fitness-steps');
  });

  test('Löschen entfernt das Layout', () async {
    final layout = custom(id: 'custom-del');
    await repo.save(layout);
    await repo.delete('custom-del');

    final all = await repo.listAll();
    expect(all.where((l) => l.id == 'custom-del'), isEmpty);
  });

  test('speichern ungültiger Layouts schlägt fehl (fail-closed)', () async {
    final bad = DashboardLayout(
      id: 'bad-1',
      name: 'Ungültig',
      area: HealthArea.gesundheit,
      widgets: [
        WidgetConfig(
          id: 'bw1',
          type: WidgetType.metricCard,
          index: 0,
          size: const WidgetSize(cols: 1, rows: 1),
          props: const {'seriesId': 'health-weight'},
        ),
        // Index-Lücke → ungültig.
        WidgetConfig(
          id: 'bw2',
          type: WidgetType.metricCard,
          index: 7,
          size: const WidgetSize(cols: 1, rows: 1),
          props: const {'seriesId': 'health-systolic'},
        ),
      ],
    );
    expect(() => repo.save(bad), throwsA(isA<ValidationException>()));
  });
}
