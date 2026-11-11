import 'package:flutter_test/flutter_test.dart';
import 'package:health_platform/core/domain/health_area.dart';
import 'package:health_platform/core/errors.dart';
import 'package:health_platform/features/dashboard/domain/dashboard_schema.dart';
import 'package:health_platform/features/dashboard/domain/dashboard_validator.dart';

DashboardLayout validLayout({
  List<WidgetConfig> widgets = const [],
  int schemaVersion = kDashboardSchemaVersion,
  String name = 'Test-Layout',
}) => DashboardLayout(
  schemaVersion: schemaVersion,
  id: 'layout-test',
  name: name,
  area: HealthArea.gesundheit,
  widgets: widgets,
);

WidgetConfig widget({
  int index = 0,
  WidgetType type = WidgetType.metricCard,
  WidgetSize? size,
  Map<String, Object?>? props,
  String id = 'w1',
}) => WidgetConfig(
  id: id,
  type: type,
  index: index,
  size: size ?? const WidgetSize(cols: 1, rows: 1),
  props: props ?? const {'seriesId': 'health-weight'},
);

void main() {
  group('validate', () {
    test('gültiges Layout → keine Fehler', () {
      final layout = validLayout(
        widgets: [
          widget(),
          widget(
            index: 1,
            id: 'w2',
            type: WidgetType.lineChart,
            size: const WidgetSize(cols: 2, rows: 2),
          ),
        ],
      );
      expect(DashboardValidator.validate(layout), isEmpty);
    });

    test('falsche Schema-Version wird abgelehnt', () {
      final layout = validLayout(schemaVersion: 99);
      expect(
        DashboardValidator.validate(layout),
        anyElement(contains('Schema-Version')),
      );
    });

    test('leerer Name wird abgelehnt', () {
      expect(
        DashboardValidator.validate(validLayout(name: '   ')),
        anyElement(contains('Name')),
      );
    });

    test('Index-Lücken werden abgelehnt', () {
      final layout = validLayout(
        widgets: [
          widget(),
          widget(index: 5, id: 'w2'),
        ],
      );
      expect(
        DashboardValidator.validate(layout),
        anyElement(contains('Indexe')),
      );
    });

    test('Größe außerhalb 1–4 / 1–3 wird abgelehnt', () {
      final tooWide = validLayout(
        widgets: [widget(size: const WidgetSize(cols: 5, rows: 1))],
      );
      final tooTall = validLayout(
        widgets: [widget(size: const WidgetSize(cols: 1, rows: 4))],
      );
      expect(
        DashboardValidator.validate(tooWide),
        anyElement(contains('Breite')),
      );
      expect(
        DashboardValidator.validate(tooTall),
        anyElement(contains('Höhe')),
      );
    });

    test('mehr als maxWidgets wird abgelehnt', () {
      final layout = validLayout(
        widgets: [
          for (var i = 0; i < DashboardValidator.maxWidgets + 1; i++)
            widget(index: i, id: 'w$i'),
        ],
      );
      expect(
        DashboardValidator.validate(layout),
        anyElement(contains('Maximal')),
      );
    });
  });

  group('validateProps', () {
    test('erlaubte Props mit korrekten Werten → valide', () {
      expect(
        DashboardValidator.validateProps(WidgetType.progress, {
          'seriesId': 'health-weight',
          'target': 8.0,
        }),
        isEmpty,
      );
      expect(
        DashboardValidator.validateProps(WidgetType.table, {
          'seriesId': 'x',
          'rows': 5,
          'title': 'Meine Tabelle',
        }),
        isEmpty,
      );
    });

    test('unbekannte Keys werden abgelehnt', () {
      expect(
        DashboardValidator.validateProps(WidgetType.metricCard, {
          'evil': 'script',
        }),
        anyElement(contains('Nicht erlaubtes')),
      );
    });

    test('falsche Typen/Werte werden abgelehnt', () {
      expect(
        DashboardValidator.validateProps(WidgetType.progress, {'target': -1}),
        anyElement(contains('ungültigen Wert')),
      );
      expect(
        DashboardValidator.validateProps(WidgetType.table, {'rows': 0}),
        anyElement(contains('ungültigen Wert')),
      );
      expect(
        DashboardValidator.validateProps(WidgetType.table, {'rows': 21}),
        anyElement(contains('ungültigen Wert')),
      );
      expect(
        DashboardValidator.validateProps(WidgetType.metricCard, {
          'seriesId': '',
        }),
        anyElement(contains('ungültigen Wert')),
      );
    });

    test('target ist bei table nicht erlaubt', () {
      expect(
        DashboardValidator.validateProps(WidgetType.table, {'target': 5.0}),
        anyElement(contains('Nicht erlaubtes')),
      );
    });
  });

  group('sanitizeProps', () {
    test('unbekannte Keys werden verworfen, erlaubte behalten', () {
      final out = DashboardValidator.sanitizeProps(WidgetType.progress, {
        'seriesId': 'health-weight',
        'target': 8.0,
        'onclick': 'alert(1)',
      });
      expect(out, {'seriesId': 'health-weight', 'target': 8.0});
    });
  });

  group('ensureValid', () {
    test('wirft ValidationException bei ungültigem Layout', () {
      final layout = validLayout(name: '');
      expect(
        () => DashboardValidator.ensureValid(layout),
        throwsA(isA<ValidationException>()),
      );
    });

    test('wirft nichts bei gültigem Layout', () {
      expect(
        () => DashboardValidator.ensureValid(validLayout()),
        returnsNormally,
      );
    });
  });
}
