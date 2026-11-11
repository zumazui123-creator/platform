import 'package:flutter_test/flutter_test.dart';
import 'package:health_platform/core/domain/health_area.dart';
import 'package:health_platform/core/errors.dart';
import 'package:health_platform/features/dashboard/domain/dashboard_schema.dart';
import 'package:health_platform/features/dashboard/domain/schema_json.dart';

DashboardLayout sampleLayout() => DashboardLayout(
  id: 'layout-x',
  name: 'Mein Layout',
  area: HealthArea.psychologie,
  widgets: [
    WidgetConfig(
      id: 'w1',
      type: WidgetType.lineChart,
      index: 0,
      size: const WidgetSize(cols: 2, rows: 2),
      props: const {'seriesId': 'psych-mood', 'title': 'Stimmung'},
    ),
    WidgetConfig(
      id: 'w2',
      type: WidgetType.progress,
      index: 1,
      size: const WidgetSize(cols: 1, rows: 1),
      props: const {'seriesId': 'psych-sleep-h', 'target': 8.0},
    ),
  ],
);

void main() {
  group('Roundtrip', () {
    test('Layout → JSON → identisches Layout', () {
      final layout = sampleLayout();
      final json = layoutToJsonString(layout);
      final parsed = parseLayoutString(json);

      expect(parsed.id, layout.id);
      expect(parsed.name, layout.name);
      expect(parsed.area, layout.area);
      expect(parsed.schemaVersion, kDashboardSchemaVersion);
      expect(parsed.widgets.length, 2);

      final w1 = parsed.widgets[0];
      expect(w1.id, 'w1');
      expect(w1.type, WidgetType.lineChart);
      expect(w1.size.cols, 2);
      expect(w1.size.rows, 2);
      expect(w1.props['seriesId'], 'psych-mood');
      expect(w1.seriesId, 'psych-mood');
      expect(w1.title, 'Stimmung');

      expect(parsed.widgets[1].type, WidgetType.progress);
      expect(parsed.widgets[1].props['target'], 8.0);
    });

    test('leeres Layout (0 Bausteine) roundtript', () {
      final layout = DashboardLayout(
        id: 'layout-empty',
        name: 'Leer',
        area: HealthArea.fitness,
      );
      final parsed = parseLayoutString(layoutToJsonString(layout));
      expect(parsed.widgets, isEmpty);
    });
  });

  group('Rejection (fail-closed)', () {
    test('falsche Schema-Version wird abgelehnt', () {
      expect(
        () => parseLayoutString(
          '{"schemaVersion": 42, "id": "x", '
          '"name": "n", "area": "fitness", "widgets": []}',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('unbekannter Bereich wird abgelehnt', () {
      expect(
        () => parseLayoutString(
          '{"schemaVersion": 1, "id": "x", '
          '"name": "n", "area": "ernährung", "widgets": []}',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('ungültiges JSON wird abgelehnt', () {
      expect(
        () => parseLayoutString('{kaputt'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Wurzel-Liste (kein Objekt) wird abgelehnt', () {
      expect(
        () => parseLayoutString('[1,2,3]'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('unbekannter Widget-Typ wird abgelehnt', () {
      expect(
        () => parseLayoutString(
          '{"schemaVersion": 1, "id": "x", '
          '"name": "n", "area": "fitness", '
          '"widgets": [{"id":"w1","type":"iframe","index":0,'
          '"size":{"cols":1,"rows":1},"props":{}}]}',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('unzulässige Größe wird abgelehnt', () {
      expect(
        () => parseLayoutString(
          '{"schemaVersion": 1, "id": "x", '
          '"name": "n", "area": "fitness", '
          '"widgets": [{"id":"w1","type":"metricCard","index":0,'
          '"size":{"cols":9,"rows":1},"props":{}}]}',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
