import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/health_area.dart';
import '../../../core/errors.dart';
import '../../../core/providers.dart';
import '../data/dashboard_repository.dart';
import '../data/local_dashboard_repository.dart';
import '../data/supabase_dashboard_repository.dart';
import 'dashboard_schema.dart';
import 'dashboard_validator.dart';

/// Zustand aller Dashboards (alle Bereiche) inkl. aktiver Auswahl.
class DashboardState {
  const DashboardState({
    required this.layouts,
    required this.activeByArea,
    required this.isDemo,
  });

  /// Alle Layouts, gruppiert nach Bereich.
  final Map<HealthArea, List<DashboardLayout>> layouts;

  /// Aktives Layout je Bereich (ID).
  final Map<HealthArea, String> activeByArea;

  /// True, wenn die Persistenz eine Demo-Quelle ist (UI-Kennzeichnung).
  final bool isDemo;

  /// Aktives Layout eines Bereichs (oder null).
  DashboardLayout? activeLayout(HealthArea area) {
    final id = activeByArea[area];
    if (id == null) return null;
    for (final l in layouts[area] ?? const <DashboardLayout>[]) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Kopie mit einem Layout ersetzt/neu eingefügt.
  DashboardState withLayout(HealthArea area, DashboardLayout layout) {
    final list = List<DashboardLayout>.of(layouts[area] ?? const []);
    final idx = list.indexWhere((l) => l.id == layout.id);
    if (idx >= 0) {
      list[idx] = layout;
    } else {
      list.add(layout);
    }
    return DashboardState(
      layouts: {...layouts, area: list},
      activeByArea: activeByArea,
      isDemo: isDemo,
    );
  }

  DashboardState copyWithActive(HealthArea area, String layoutId) =>
      DashboardState(
        layouts: layouts,
        activeByArea: {...activeByArea, area: layoutId},
        isDemo: isDemo,
      );
}

/// Zentrale Store für Dashboard-Layouts: Lade, speichere und wende
/// alle Baukasten-Operationen an (immer mit Validierung).
///
/// Alle Mutationen sind atomar: Transform → Reindex → Validierung →
/// Persistenz → State-Update. Ein fehlerhafter Schritt ändert nichts.
class DashboardStore extends AsyncNotifier<DashboardState> {
  DashboardRepository? _repo;

  DashboardRepository get repo {
    _repo ??= ref.watch(dashboardRepositoryProvider);
    return _repo!;
  }

  @override
  Future<DashboardState> build() async {
    final all = await repo.listAll();
    final byArea = <HealthArea, List<DashboardLayout>>{
      for (final area in HealthArea.values) area: <DashboardLayout>[],
    };
    for (final l in all) {
      byArea.putIfAbsent(l.area, () => <DashboardLayout>[]).add(l);
    }
    final active = <HealthArea, String?>{
      for (final area in HealthArea.values)
        area: (byArea[area]!.isEmpty ? null : byArea[area]!.first.id),
    };
    return DashboardState(
      layouts: byArea,
      activeByArea: {
        for (final e in active.entries)
          if (e.value != null) e.key: e.value!,
      },
      isDemo: repo.isDemo,
    );
  }

  /// Fügt einen Baustein an das Ende des aktiven Layouts hinzu.
  Future<void> addWidget(
    HealthArea area,
    WidgetType type, {
    WidgetSize? size,
    Map<String, Object?>? props,
  }) => _transformLayout(area, (layout) {
    final cleanProps = DashboardValidator.sanitizeProps(type, props ?? {});
    final widget = WidgetConfig(
      id: newWidgetId(),
      type: type,
      index: layout.widgets.length,
      size: size ?? const WidgetSize(cols: 2, rows: 2),
      props: cleanProps,
    );
    return layout.copyWith(widgets: [...layout.widgets, widget]);
  });

  /// Entfernt einen Baustein.
  Future<void> removeWidget(HealthArea area, String widgetId) =>
      _transformLayout(
        area,
        (layout) => layout.copyWith(
          widgets: [
            for (final w in layout.widgets)
              if (w.id != widgetId) w,
          ],
        ),
      );

  /// Verschiebt einen Baustein auf Position [toIndex].
  Future<void> moveWidget(HealthArea area, String widgetId, int toIndex) =>
      _transformLayout(area, (layout) {
        final from = layout.widgets.indexWhere((w) => w.id == widgetId);
        if (from < 0) throw NotFoundException('Baustein nicht gefunden.');
        final list = List<WidgetConfig>.of(layout.widgets);
        final w = list.removeAt(from);
        final clamped = toIndex.clamp(0, list.length);
        list.insert(clamped, w);
        return layout.copyWith(widgets: list);
      });

  /// Ändert Größe eines Bausteins (validiert: 1–4 Spalten, 1–3 Reihen).
  Future<void> resizeWidget(
    HealthArea area,
    String widgetId,
    WidgetSize newSize,
  ) => _transformLayout(
    area,
    (layout) => layout.copyWith(
      widgets: [
        for (final w in layout.widgets)
          if (w.id == widgetId) w.copyWith(size: newSize) else w,
      ],
    ),
  );

  /// Aktualisiert die Props eines Bausteins (sanitiert + validiert).
  Future<void> updateWidgetProps(
    HealthArea area,
    String widgetId,
    Map<String, Object?> props,
  ) => _transformLayout(
    area,
    (layout) => layout.copyWith(
      widgets: [
        for (final w in layout.widgets)
          if (w.id == widgetId)
            w.copyWith(props: DashboardValidator.sanitizeProps(w.type, props))
          else
            w,
      ],
    ),
  );

  /// Legt ein neues (leeres) Layout an und macht es aktiv.
  Future<String> createLayout(HealthArea area, String name) async {
    final layout = DashboardLayout(
      id: newLayoutId(),
      name: name.trim(),
      area: area,
      widgets: const [],
    );
    DashboardValidator.ensureValid(layout);
    await repo.save(layout);
    final current = state.value ?? _emptyState();
    state = AsyncData(
      current.withLayout(area, layout).copyWithActive(area, layout.id),
    );
    return layout.id;
  }

  /// Benennt ein Layout um.
  Future<void> renameLayout(String layoutId, String name) =>
      _transformLayoutById(
        layoutId,
        (l) => l.copyWith(name: name),
        requireName: true,
      );

  /// Löscht ein Layout (aktiv wird auf das nächste verfügbare umgestellt).
  Future<void> deleteLayout(String layoutId) async {
    final current = state.value;
    if (current == null) return;
    DashboardLayout? victim;
    for (final l in current.layouts.values.expand((x) => x)) {
      if (l.id == layoutId) victim = l;
    }
    if (victim == null) return;
    await repo.delete(layoutId);
    var next = current;
    for (final e in current.layouts.entries) {
      final list = [
        for (final l in e.value)
          if (l.id != layoutId) l,
      ];
      next = DashboardState(
        layouts: {...next.layouts, e.key: list},
        activeByArea: next.activeByArea,
        isDemo: next.isDemo,
      );
    }
    // Aktive Pointer bereinigen.
    final active = <HealthArea, String?>{...next.activeByArea};
    for (final area in HealthArea.values) {
      if (active[area] == layoutId) {
        active[area] = next.layouts[area]?.first.id;
      }
    }
    next = DashboardState(
      layouts: next.layouts,
      activeByArea: {
        for (final e in active.entries)
          if (e.value != null) e.key: e.value!,
      },
      isDemo: next.isDemo,
    );
    state = AsyncData(next);
  }

  /// Setzt das aktive Layout eines Bereichs.
  Future<void> setActiveLayout(HealthArea area, String layoutId) async {
    final current = state.value;
    if (current == null) return;
    final exists = (current.layouts[area] ?? const []).any(
      (l) => l.id == layoutId,
    );
    if (!exists) throw NotFoundException('Layout existiert nicht.');
    state = AsyncData(current.copyWithActive(area, layoutId));
    // Persistenz des aktiven Pointers (Best-Effort, lokal im State).
  }

  Future<void> _transformLayout(
    HealthArea area,
    DashboardLayout Function(DashboardLayout) transform,
  ) => _transformLayoutById((state.value)?.activeByArea[area], transform);

  Future<void> _transformLayoutById(
    String? layoutId,
    DashboardLayout Function(DashboardLayout) transform, {
    bool requireName = false,
  }) async {
    final current = state.value;
    final id = layoutId;
    if (current == null || id == null) {
      throw NotFoundException('Kein aktives Layout gefunden.');
    }
    DashboardLayout? layout;
    for (final l in current.layouts.values.expand((x) => x)) {
      if (l.id == id) layout = l;
    }
    if (layout == null) {
      throw NotFoundException('Layout "$id" existiert nicht.');
    }
    var updated = transform(layout);
    if (requireName && updated.name.trim().isEmpty) {
      throw ValidationException('Name darf nicht leer sein.');
    }
    // Indexe neu aufbauen (lückenlos ab 0) — hält die Invariante.
    updated = updated.copyWith(
      widgets: [
        for (var i = 0; i < updated.widgets.length; i++)
          if (updated.widgets[i].index != i)
            updated.widgets[i].copyWith(index: i)
          else
            updated.widgets[i],
      ],
    );
    DashboardValidator.ensureValid(updated);
    await repo.save(updated);
    state = AsyncData(current.withLayout(updated.area, updated));
  }

  DashboardState _emptyState() => DashboardState(
    layouts: {
      for (final area in HealthArea.values) area: const <DashboardLayout>[],
    },
    activeByArea: const {},
    isDemo: repo.isDemo,
  );
}

/// Provider: Repository-Wahl (Supabase wenn konfiguriert, sonst lokal).
String newWidgetId() => newId('w');
String newLayoutId() => newId('layout');

/// Provider: Repository-Wahl (Supabase wenn konfiguriert, sonst lokal).
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  if (ref.watch(supabaseEnabledProvider)) {
    return SupabaseDashboardRepository(ref.watch(supabaseClientProvider));
  }
  return LocalDashboardRepository(prefs);
});

final dashboardStoreProvider =
    AsyncNotifierProvider<DashboardStore, DashboardState>(DashboardStore.new);
