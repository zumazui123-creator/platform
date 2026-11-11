import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/health_area.dart';
import '../../../core/domain/metric_series.dart';
import '../../data/providers.dart';
import '../domain/dashboard_schema.dart';
import '../domain/dashboard_store.dart';
import 'widget_registry.dart';

/// Dashboard-Ansicht eines Bereichs: Layout-Leiste + Widget-Grid.
///
/// Das Grid ist ein 4-Spalten-Raster; Bausteine werden per
/// Shelf-Algorithmus in Zeilen platziert (Größen in Raster-Einheiten).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({required this.area, this.editing = false, super.key});

  final HealthArea area;
  final bool editing;

  static const double _rowHeight = 150;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardStoreProvider);
    return dash.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 8),
            Text('Dashboard konnte nicht geladen werden:\n$e'),
          ],
        ),
      ),
      data: (state) {
        final layout = state.activeLayout(area);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LayoutBar(state: state, area: area, editing: editing),
            if (layout == null || layout.widgets.isEmpty)
              Expanded(
                child: _EmptyState(editing: editing, area: area),
              )
            else
              Expanded(
                child: _WidgetGrid(layout: layout, editing: editing),
              ),
            if (editing) _EditorBar(area: area, hasLayout: layout != null),
          ],
        );
      },
    );
  }
}

class _LayoutBar extends ConsumerWidget {
  const _LayoutBar({
    required this.state,
    required this.area,
    required this.editing,
  });

  final DashboardState state;
  final HealthArea area;
  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final layouts = state.layouts[area] ?? const <DashboardLayout>[];
    final active = state.activeLayout(area);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          if (layouts.length > 1)
            Flexible(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: active?.id,
                  isExpanded: true,
                  dropdownColor: theme.colorScheme.surfaceContainerHighest,
                  items: [
                    for (final l in layouts)
                      DropdownMenuItem(
                        value: l.id,
                        child: Text(l.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (id) {
                    if (id != null) {
                      ref
                          .read(dashboardStoreProvider.notifier)
                          .setActiveLayout(area, id);
                    }
                  },
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                active?.name ?? area.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Neues Layout',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _newLayout(context, ref, area),
          ),
          IconButton(
            tooltip: 'Layout löschen',
            icon: const Icon(Icons.delete_outline),
            onPressed: active == null
                ? null
                : () => _confirmDelete(context, ref, active.id),
          ),
          if (state.isDemo)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: const Text('Demo', style: TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _newLayout(
    BuildContext context,
    WidgetRef ref,
    HealthArea area,
  ) async {
    final name = await _promptText(
      context,
      title: 'Neues Layout',
      initial:
          '${area.label} Layout ${((state.layouts[area]?.length ?? 0) + 1)}',
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(dashboardStoreProvider.notifier).createLayout(area, name);
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String layoutId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Layout löschen?'),
        content: const Text(
          'Dieses Layout und alle Bausteine werden entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(dashboardStoreProvider.notifier).deleteLayout(layoutId);
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    }
  }
}

Future<String?> _promptText(
  BuildContext context, {
  required String title,
  String? initial,
}) {
  final ctrl = TextEditingController(text: initial ?? '');
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.editing, required this.area});

  final bool editing;
  final HealthArea area;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (!editing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.widgets_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'Keine Bausteine in diesem Layout.',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Tippe auf „Bearbeiten“, um Bausteine hinzuzufügen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Leeres Layout — nutze „Baustein hinzufügen“ unten.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// Raster-Grid: platziert Bausteine per Shelf-Algorithmus (4 Spalten).
class _WidgetGrid extends ConsumerWidget {
  const _WidgetGrid({required this.layout, required this.editing});

  final DashboardLayout layout;
  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final area = layout.area;
    final rows = _Shelf.place(layout.widgets);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          for (final row in rows.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: _Shelf.bandHeight(row.value.values),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in row.value.entries)
                      Expanded(
                        flex: entry.value.size.cols,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: entry.key == 0 ? 0 : 12,
                          ),
                          child: _WidgetCard(
                            config: entry.value,
                            area: area,
                            editing: editing,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WidgetCard extends ConsumerWidget {
  const _WidgetCard({
    required this.config,
    required this.area,
    required this.editing,
  });

  final WidgetConfig config;
  final HealthArea area;
  final bool editing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spec = WidgetRegistry.specFor(config.type);

    // Serie auflösen (falls konfiguriert).
    final seriesAsync = config.seriesId == null
        ? const AsyncValue<MetricSeries?>.data(null)
        : ref.watch(seriesByIdProvider(config.seriesId!));
    final series = seriesAsync.value;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    config.title ?? series?.name ?? (spec?.type.label ?? ''),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (editing) ...[
                  IconButton(
                    tooltip: 'Größer',
                    icon: const Icon(Icons.open_in_full, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _grow(ref),
                  ),
                  IconButton(
                    tooltip: 'Kleiner',
                    icon: const Icon(Icons.fullscreen_exit, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _shrink(ref),
                  ),
                  IconButton(
                    tooltip: 'Links',
                    icon: const Icon(Icons.arrow_left, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        _move(ref, area, config.id, config.index - 1),
                  ),
                  IconButton(
                    tooltip: 'Rechts',
                    icon: const Icon(Icons.arrow_right, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        _move(ref, area, config.id, config.index + 1),
                  ),
                  IconButton(
                    tooltip: 'Einstellungen',
                    icon: const Icon(Icons.tune, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _editProps(context, ref),
                  ),
                  IconButton(
                    tooltip: 'Entfernen',
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _remove(ref, area, config.id),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: seriesAsync.when(
                loading: () => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Fehler: $e',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                data: (s) => SizedBox.expand(
                  child: WidgetRegistry.buildContent(context, ref, config, s),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _move(WidgetRef ref, HealthArea area, String id, int to) {
    if (to < 0) return;
    unawaitedSafe(
      ref.read(dashboardStoreProvider.notifier).moveWidget(area, id, to),
    );
  }

  void _grow(WidgetRef ref) {
    if (config.size.cols >= 4 && config.size.rows >= 3) return;
    unawaitedSafe(
      ref
          .read(dashboardStoreProvider.notifier)
          .resizeWidget(
            area,
            config.id,
            WidgetSize(
              cols: config.size.cols >= 4 ? 4 : config.size.cols + 1,
              rows: config.size.rows >= 3 ? 3 : config.size.rows + 1,
            ),
          ),
    );
  }

  void _shrink(WidgetRef ref) {
    if (config.size.cols <= 1 && config.size.rows <= 1) return;
    unawaitedSafe(
      ref
          .read(dashboardStoreProvider.notifier)
          .resizeWidget(
            area,
            config.id,
            WidgetSize(
              cols: config.size.cols <= 1 ? 1 : config.size.cols - 1,
              rows: config.size.rows <= 1 ? 1 : config.size.rows - 1,
            ),
          ),
    );
  }

  void _remove(WidgetRef ref, HealthArea area, String id) {
    unawaitedSafe(
      ref.read(dashboardStoreProvider.notifier).removeWidget(area, id),
    );
  }

  Future<void> _editProps(BuildContext context, WidgetRef ref) async {
    // Dialog übernimmt das Speichern selbst (merged props).
    await _WidgetSettingsDialog.edit(context, config: config, area: area);
  }
}

/// Fire-and-forget für Store-Mutationen mit Fehler-Snackbar.
void unawaitedSafe(Future<void> f) {
  f.catchError((Object e) {
    debugPrint('Dashboard-Store-Fehler: $e');
  });
}

/// Shelf-Platzierung: 4 Spalten, Bausteine in Zeilen abgelegt.
/// Rückgabe: Zeilenindex → (Spaltenstart → Baustein).
class _Shelf {
  const _Shelf._();

  static const int cols = 4;
  static const int maxRows = 8;

  /// Höhe einer Zeilen-Band: größter Widget × Rasterhöhe.
  static double bandHeight(Iterable<WidgetConfig> widgets) {
    var maxRows = 1;
    for (final w in widgets) {
      if (w.size.rows > maxRows) maxRows = w.size.rows;
    }
    return maxRows * DashboardScreen._rowHeight;
  }

  static Map<int, Map<int, WidgetConfig>> place(List<WidgetConfig> widgets) {
    final occupied = <int, Set<int>>{
      for (var r = 0; r < maxRows; r++) r: <int>{},
    };
    final result = <int, Map<int, WidgetConfig>>{};
    for (final w in widgets) {
      final width = w.size.cols.clamp(1, cols);
      outer:
      for (var r = 0; r < maxRows; r++) {
        for (var c = 0; c + width <= cols; c++) {
          var fits = true;
          for (var k = 0; k < width; k++) {
            if (occupied[r]!.contains(c + k)) {
              fits = false;
              break;
            }
          }
          if (!fits) continue;
          for (var k = 0; k < width; k++) {
            occupied[r]!.add(c + k);
          }
          // Mehrzeilige Bausteine besetzen auch folgende Zeilen.
          for (var rr = r + 1; rr < r + w.size.rows && rr < maxRows; rr++) {
            for (var k = 0; k < width; k++) {
              occupied[rr]!.add(c + k);
            }
          }
          result.putIfAbsent(r, () => <int, WidgetConfig>{})[c] = w;
          break outer;
        }
      }
    }
    // Zeilen kompakt nachrücken: keine leeren Lücken in der Ausgabe.
    final compact = <int, Map<int, WidgetConfig>>{};
    var row = 0;
    for (final e in result.entries) {
      compact[row] = e.value;
      row++;
    }
    return compact;
  }
}

// ---------------------------------------------------------------------------
// Editor
// ---------------------------------------------------------------------------

/// Unterleiste im Bearbeitungsmodus: Baustein hinzufügen.
class _EditorBar extends ConsumerWidget {
  const _EditorBar({required this.area, required this.hasLayout});

  final HealthArea area;
  final bool hasLayout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.6,
          ),
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: hasLayout
                  ? () => _AddWidgetDialog.show(context, ref, area)
                  : null,
              icon: const Icon(Icons.add),
              label: const Text('Baustein hinzufügen'),
            ),
            const SizedBox(width: 8),
            Text(
              hasLayout
                  ? 'Bausteine mit den Symbolen auf der Karte anpassen.'
                  : 'Erst ein Layout anlegen (oben „+“).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog: einen der 7 Baustein-Typen auswählen → wird ans Ende angehängt.
class _AddWidgetDialog extends ConsumerWidget {
  const _AddWidgetDialog({
    required this.context0,
    required this.ref0,
    required this.area,
  });

  final BuildContext context0;
  final WidgetRef ref0;
  final HealthArea area;

  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    HealthArea area,
  ) {
    return showDialog<void>(
      context: context,
      builder: (ctx) =>
          _AddWidgetDialog(context0: context, ref0: ref, area: area),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Serien des Bereichs für sinnvolle Standardzuordnung.
    final seriesAsync = ref.watch(seriesByAreaProvider(area));
    return AlertDialog(
      title: const Text('Baustein hinzufügen'),
      content: SizedBox(
        width: 400,
        child: seriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Fehler: $e'),
          data: (series) => ListView(
            shrinkWrap: true,
            children: [
              for (final spec in WidgetRegistry.specs)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    title: Text(spec.type.label),
                    subtitle: Text(spec.description),
                    trailing: Text(
                      '${spec.defaultSize.cols}×${spec.defaultSize.rows}',
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _add(context, ref, spec, series);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }

  void _add(
    BuildContext context,
    WidgetRef ref,
    WidgetSpec spec,
    List<MetricSeries> series,
  ) {
    // Erste passende Serie des Bereichs als Standard.
    final first = series.isNotEmpty ? series.first.id : null;
    final props = <String, Object?>{...spec.defaultProps};
    if (first != null) props['seriesId'] = first;
    unawaitedSafe(
      ref
          .read(dashboardStoreProvider.notifier)
          .addWidget(area, spec.type, size: spec.defaultSize, props: props),
    );
  }
}

/// Einstellungen-Dialog eines Bausteins: Serie wählen, Ziel/Zeilen.
class _WidgetSettingsDialog {
  const _WidgetSettingsDialog._();

  static Future<String?> edit(
    BuildContext context, {
    required WidgetConfig config,
    required HealthArea area,
  }) {
    return showDialog<String?>(
      context: context,
      builder: (ctx) => _WidgetSettingsDialogBody(config: config, area: area),
    );
  }
}

class _WidgetSettingsDialogBody extends ConsumerStatefulWidget {
  const _WidgetSettingsDialogBody({required this.config, required this.area});

  final WidgetConfig config;
  final HealthArea area;

  @override
  ConsumerState<_WidgetSettingsDialogBody> createState() =>
      _WidgetSettingsDialogBodyState();
}

class _WidgetSettingsDialogBodyState
    extends ConsumerState<_WidgetSettingsDialogBody> {
  late String? _seriesId;
  late double _target;
  late int _rows;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _seriesId = widget.config.seriesId;
    _target = (widget.config.props['target'] as num?)?.toDouble() ?? 8.0;
    _rows = (widget.config.props['rows'] as int?) ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seriesAsync = ref.watch(seriesByAreaProvider(widget.area));
    return AlertDialog(
      title: Text(
        'Baustein: ${WidgetRegistry.specFor(widget.config.type)?.type.label ?? ''}',
      ),
      content: SizedBox(
        width: 400,
        child: seriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Fehler: $e'),
          data: (series) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: _seriesId,
                decoration: const InputDecoration(labelText: 'Messserie'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('– keine –'),
                  ),
                  for (final s in series)
                    DropdownMenuItem<String?>(
                      value: s.id,
                      child: Text(
                        '${s.name} (${s.unit})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _seriesId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.config.type == WidgetType.progress
                          ? 'Zielwert'
                          : 'Zeilen (Tabelle)',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: widget.config.type == WidgetType.progress
                        ? TextFormField(
                            initialValue: _target.toString(),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) =>
                                _target = double.tryParse(v) ?? _target,
                          )
                        : TextFormField(
                            initialValue: '$_rows',
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (v) => _rows = int.tryParse(v) ?? _rows,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  try {
                    // Bestehende Props mergen (nur relevante Keys setzen).
                    final merged = <String, Object?>{...widget.config.props};
                    if (_seriesId != null) {
                      merged['seriesId'] = _seriesId;
                    } else {
                      merged.remove('seriesId');
                    }
                    merged['target'] = _target;
                    merged['rows'] = _rows;
                    await ref
                        .read(dashboardStoreProvider.notifier)
                        .updateWidgetProps(
                          widget.area,
                          widget.config.id,
                          merged,
                        );
                    if (context.mounted) Navigator.pop(context);
                  } on Object catch (e) {
                    if (context.mounted) {
                      setState(() => _busy = false);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Fehler: $e')));
                    }
                  }
                },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
