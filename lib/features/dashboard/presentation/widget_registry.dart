import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../charts/domain/chart_engine.dart';
import '../../../core/domain/metric_series.dart';
import '../domain/dashboard_schema.dart';

/// Die zentrale Widget-Registry des UI-Baukastens.
///
/// Eindeutige Zuordnung [WidgetType] → [WidgetSpec] (Standard-Größe,
/// Standard-Props) + Builder für den Inhalt. JSON-Konfigurationen
/// werden ausschließlich hier zu echten Widgets aufgelöst — es wird
/// niemals Code aus Konfigurationen ausgeführt.

/// Spezifikation eines Baustein-Typs.
class WidgetSpec {
  const WidgetSpec({
    required this.type,
    required this.defaultSize,
    this.defaultProps = const {},
    required this.description,
  });

  final WidgetType type;
  final WidgetSize defaultSize;
  final Map<String, Object?> defaultProps;
  final String description;
}

class WidgetRegistry {
  const WidgetRegistry._();

  /// Alle verfügbaren Baustein-Typen (Reihenfolge = Editor-Dialog).
  static const List<WidgetSpec> specs = [
    WidgetSpec(
      type: WidgetType.metricCard,
      defaultSize: WidgetSize(cols: 1, rows: 1),
      description: 'Eine einzelne Kennzahl (z. B. aktueller Wert).',
    ),
    WidgetSpec(
      type: WidgetType.statCard,
      defaultSize: WidgetSize(cols: 1, rows: 1),
      description: 'Kennzahl mit 7-Tage-Trend (Delta).',
    ),
    WidgetSpec(
      type: WidgetType.lineChart,
      defaultSize: WidgetSize(cols: 2, rows: 2),
      description: 'Verlauf über die Zeit.',
    ),
    WidgetSpec(
      type: WidgetType.barChart,
      defaultSize: WidgetSize(cols: 2, rows: 2),
      description: 'Wochen-Summen als Balken.',
    ),
    WidgetSpec(
      type: WidgetType.pieChart,
      defaultSize: WidgetSize(cols: 2, rows: 2),
      description: 'Verteilung als Anteile.',
    ),
    WidgetSpec(
      type: WidgetType.progress,
      defaultSize: WidgetSize(cols: 1, rows: 1),
      defaultProps: {'target': 8.0},
      description: 'Fortschritt gegen ein Ziel.',
    ),
    WidgetSpec(
      type: WidgetType.table,
      defaultSize: WidgetSize(cols: 2, rows: 2),
      defaultProps: {'rows': 5},
      description: 'Tabelle der letzten Messwerte.',
    ),
  ];

  static WidgetSpec? specFor(WidgetType type) {
    for (final s in specs) {
      if (s.type == type) return s;
    }
    return null;
  }

  /// Baut den Inhalt eines konfigurierten Bausteins.
  /// [series] = aufgelöste Serie (aus props['seriesId']), kann null sein.
  static Widget buildContent(
    BuildContext context,
    WidgetRef ref,
    WidgetConfig config,
    MetricSeries? series,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (series == null) {
      return _NeedsSeries(
        type: config.type,
        seriesId: config.seriesId,
        scheme: scheme,
      );
    }

    final color = scheme.primary;
    final color2 = scheme.secondary;
    final color3 = scheme.tertiary;

    return switch (config.type) {
      WidgetType.metricCard => _MetricCard(series: series),
      WidgetType.statCard => _StatCard(series: series),
      WidgetType.lineChart => _LineChartWidget(
        spots: ChartEngine.lineSpots(series),
        range: ChartEngine.lineRange(series),
        color: color,
        unit: series.unit,
      ),
      WidgetType.barChart => _BarChartWidget(
        values: ChartEngine.weeklyValues(series, weeks: 8, sum: true),
        color: color,
        unit: series.unit,
      ),
      WidgetType.pieChart => _PieChartWidget(
        slices: ChartEngine.pieSlices(series, maxSlices: 7),
        colors: [
          color,
          color2,
          color3,
          scheme.error,
          scheme.primaryContainer,
          scheme.secondaryContainer,
          scheme.tertiaryContainer,
        ],
        unit: series.unit,
      ),
      WidgetType.progress => _ProgressWidget(
        series: series,
        target: (config.props['target'] as num?)?.toDouble() ?? 10,
      ),
      WidgetType.table => _TableWidget(
        series: series,
        rows: (config.props['rows'] as int?) ?? 5,
      ),
    };
  }
}

// ---------------------------------------------------------------------------
// Einzel-Bausteine (privat)
// ---------------------------------------------------------------------------

class _NeedsSeries extends StatelessWidget {
  const _NeedsSeries({
    required this.type,
    required this.seriesId,
    required this.scheme,
  });

  final WidgetType type;
  final String? seriesId;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final spec = WidgetRegistry.specFor(type);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        seriesId == null
            ? '${spec?.type.label ?? type.name}: keine Serie ausgewählt.\nIm Editor eintragen.'
            : '${spec?.type.label ?? type.name}: Serie "$seriesId" nicht gefunden.',
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.series});

  final MetricSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = series.last ?? 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          series.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _fmt(last) + (series.unit.isEmpty ? '' : ' ${series.unit}'),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${series.points.length} Messungen · Ø ${_fmt(series.average)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.series});

  final MetricSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (last, delta) = ChartEngine.lastAndDelta(series, daysBefore: 7);
    final up = (delta ?? 0) >= 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          series.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                _fmt(last) + (series.unit.isEmpty ? '' : ' ${series.unit}'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (delta != null)
              Container(
                margin: const EdgeInsets.only(bottom: 2, left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (up ? Colors.green : Colors.orange).withValues(
                    alpha: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${up ? '▲' : '▼'} ${_fmt(delta.abs())}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: up ? Colors.green : Colors.orange,
                  ),
                ),
              ),
          ],
        ),
        Text(
          '7-Tage-Trend',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  const _LineChartWidget({
    required this.spots,
    required this.range,
    required this.color,
    required this.unit,
  });

  final List<FlSpot> spots;
  final (double, double) range;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (spots.length < 2) {
      return const Center(child: Text('Zu wenige Datenpunkte.'));
    }
    final minV = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxV = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final pad = (maxV - minV) * 0.1 + 1e-9;
    return LineChart(
      LineChartData(
        minY: minV - pad,
        maxY: maxV + pad,
        minX: range.$1,
        maxX: range.$2,
        lineTouchData: const LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxV + pad - (minV - pad)) / 3,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 0.6,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (range.$2 - range.$1) / 2,
              getTitlesWidget: (value, meta) {
                final d = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${d.day}.${d.month}.',
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            barWidth: 2.2,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  const _BarChartWidget({
    required this.values,
    required this.color,
    required this.unit,
  });

  final List<double> values;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (values.isEmpty) {
      return const Center(child: Text('Keine Daten.'));
    }
    final maxV = values.fold<double>(0, (a, b) => a > b ? a : b) * 1.15 + 1e-9;
    return BarChart(
      BarChartData(
        maxY: maxV,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= values.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'W${i + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 14,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  color: color.withValues(
                    alpha: i == values.length - 1 ? 1 : 0.55,
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  const _PieChartWidget({
    required this.slices,
    required this.colors,
    required this.unit,
  });

  final List<double> slices;
  final List<Color> colors;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (slices.isEmpty) {
      return const Center(child: Text('Keine Daten.'));
    }
    final total = ChartEngine.pieTotal(slices);
    final sections = [
      for (var i = 0; i < slices.length; i++)
        PieChartSectionData(
          value: slices[i],
          color: colors[i % colors.length],
          radius: 26,
          title: '',
          showTitle: false,
        ),
    ];
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 1.5,
              centerSpaceRadius: 22,
              pieTouchData: PieTouchData(enabled: false),
            ),
          ),
        ),
        SizedBox(
          width: 74,
          child: ListView(
            children: [
              for (var i = 0; i < slices.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors[i % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${total == 0 ? 0 : (slices[i] / total * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressWidget extends StatelessWidget {
  const _ProgressWidget({required this.series, required this.target});

  final MetricSeries series;
  final double target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = series.last ?? 0;
    final pct = target <= 0 ? 0.0 : (last / target).clamp(0.0, 1.5);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          series.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (pct / 1.5).clamp(0.0, 1.0),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_fmt(last)} / ${_fmt(target)} ${series.unit} · '
          '${(pct * 100).toStringAsFixed(0)}% vom Ziel',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TableWidget extends StatelessWidget {
  const _TableWidget({required this.series, required this.rows});

  final MetricSeries series;
  final int rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pts = series.points;
    if (pts.isEmpty) {
      return const Center(child: Text('Keine Daten.'));
    }
    final last = pts.length >= rows ? pts.sublist(pts.length - rows) : pts;
    return ListView.builder(
      itemCount: last.length,
      itemBuilder: (context, i) {
        final p = last[last.length - 1 - i]; // neueste zuerst
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${p.date.day.toString().padLeft(2, '0')}.${p.date.month.toString().padLeft(2, '0')}.${p.date.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _fmt(p.value) + (series.unit.isEmpty ? '' : ' ${series.unit}'),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _fmt(double v) => v.abs() >= 100
    ? v.toStringAsFixed(0)
    : v.toStringAsFixed(1).replaceAll('.', ',');
