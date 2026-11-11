import '../../../core/domain/health_area.dart';
import '../domain/dashboard_schema.dart';
import '../domain/schema_json.dart';

/// Beispiel-Layouts für den ersten Start (einer pro Bereich).
///
/// Werden von [LocalDashboardRepository] seeded, wenn noch keine
/// eigenen Layouts existieren — die App startet nie mit einem leeren
/// Dashboard, sondern zeigt sofort, was der Baukasten kann.
List<DashboardLayout> defaultLayouts() => [
  DashboardLayout(
    id: 'default-gesundheit',
    name: 'Gesundheit Standard',
    area: HealthArea.gesundheit,
    widgets: [
      WidgetConfig(
        id: 'gw-weight',
        type: WidgetType.metricCard,
        index: 0,
        size: const WidgetSize(cols: 1, rows: 1),
        props: const {'seriesId': 'health-weight'},
      ),
      WidgetConfig(
        id: 'gw-systolic-trend',
        type: WidgetType.statCard,
        index: 1,
        size: const WidgetSize(cols: 1, rows: 1),
        props: const {'seriesId': 'health-systolic'},
      ),
      WidgetConfig(
        id: 'gw-weight-line',
        type: WidgetType.lineChart,
        index: 2,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'health-weight'},
      ),
      WidgetConfig(
        id: 'gw-systolic-line',
        type: WidgetType.lineChart,
        index: 3,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'health-systolic'},
      ),
      WidgetConfig(
        id: 'gw-weight-table',
        type: WidgetType.table,
        index: 4,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'health-weight', 'rows': 5},
      ),
    ],
  ),
  DashboardLayout(
    id: 'default-fitness',
    name: 'Fitness Standard',
    area: HealthArea.fitness,
    widgets: [
      WidgetConfig(
        id: 'fw-steps',
        type: WidgetType.metricCard,
        index: 0,
        size: const WidgetSize(cols: 1, rows: 1),
        props: const {'seriesId': 'fitness-steps'},
      ),
      WidgetConfig(
        id: 'fw-vo2-trend',
        type: WidgetType.statCard,
        index: 1,
        size: const WidgetSize(cols: 1, rows: 1),
        props: const {'seriesId': 'fitness-vo2max'},
      ),
      WidgetConfig(
        id: 'fw-steps-bar',
        type: WidgetType.barChart,
        index: 2,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'fitness-steps'},
      ),
      WidgetConfig(
        id: 'fw-cal-line',
        type: WidgetType.lineChart,
        index: 3,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'fitness-calories'},
      ),
      WidgetConfig(
        id: 'fw-workout-pie',
        type: WidgetType.pieChart,
        index: 4,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'fitness-workout-min'},
      ),
    ],
  ),
  DashboardLayout(
    id: 'default-psychologie',
    name: 'Psychologie Standard',
    area: HealthArea.psychologie,
    widgets: [
      WidgetConfig(
        id: 'pw-mood',
        type: WidgetType.metricCard,
        index: 0,
        size: const WidgetSize(cols: 1, rows: 1),
        props: const {'seriesId': 'psych-mood'},
      ),
      WidgetConfig(
        id: 'pw-sleep-progress',
        type: WidgetType.progress,
        index: 1,
        size: const WidgetSize(cols: 1, rows: 1),
        props: const {'seriesId': 'psych-sleep-h', 'target': 8.0},
      ),
      WidgetConfig(
        id: 'pw-mood-line',
        type: WidgetType.lineChart,
        index: 2,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'psych-mood'},
      ),
      WidgetConfig(
        id: 'pw-stress-line',
        type: WidgetType.lineChart,
        index: 3,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'psych-stress'},
      ),
      WidgetConfig(
        id: 'pw-sleep-table',
        type: WidgetType.table,
        index: 4,
        size: const WidgetSize(cols: 2, rows: 2),
        props: const {'seriesId': 'psych-sleep-h', 'rows': 5},
      ),
    ],
  ),
];

/// Erzeugt eine frische Kopie der Standard-Layouts (für Tests/Seed).
List<DashboardLayout> freshDefaultLayouts() => [
  for (final l in defaultLayouts()) parseLayoutString(layoutToJsonString(l)),
];
