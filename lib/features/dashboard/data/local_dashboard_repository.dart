import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors.dart';
import '../domain/dashboard_schema.dart';
import '../domain/dashboard_validator.dart';
import '../domain/schema_json.dart';
import 'dashboard_repository.dart';
import 'default_layouts.dart';

/// Lokale Persistenz (shared_preferences — auf Web: localStorage, auf
/// Mobile: SharedPreferences-Storage).
///
/// Wird genutzt, wenn kein Supabase-Projekt konfiguriert ist. Bei
/// erstem Start werden Beispiel-Layouts seeded.
class LocalDashboardRepository implements DashboardRepository {
  LocalDashboardRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _storageKey = 'dashboard_layouts_v1';

  @override
  bool get isDemo => true;

  /// Lädt (bzw. seedet) den gesamten Layout-Stand.
  @override
  Future<List<DashboardLayout>> listAll() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) {
      final seeded = freshDefaultLayouts();
      await _writeAll(seeded);
      return seeded;
    }
    return _decode(raw);
  }

  @override
  Future<DashboardLayout?> load(String id) async {
    for (final l in await listAll()) {
      if (l.id == id) return l;
    }
    return null;
  }

  @override
  Future<void> save(DashboardLayout layout) async {
    DashboardValidator.ensureValid(layout);
    final all = await listAll();
    final idx = all.indexWhere((l) => l.id == layout.id);
    final next = List<DashboardLayout>.of(all);
    if (idx >= 0) {
      next[idx] = layout;
    } else {
      next.add(layout);
    }
    await _writeAll(next);
  }

  @override
  Future<void> delete(String id) async {
    final all = await listAll();
    await _writeAll([
      for (final l in all)
        if (l.id != id) l,
    ]);
  }

  Future<void> _writeAll(List<DashboardLayout> layouts) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode([for (final l in layouts) layoutToJson(l)]),
    );
  }

  List<DashboardLayout> _decode(String raw) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      // Beschädigter Stand → neu seeden statt App-Absturz.
      return freshDefaultLayouts();
    }
    if (decoded is! List) return freshDefaultLayouts();
    final out = <DashboardLayout>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      try {
        final l = parseLayout(item);
        DashboardValidator.ensureValid(l);
        out.add(l);
      } on AppException {
        // Ungültige Einzel-Layouts werden verworfen, nicht die ganze App.
      }
    }
    return out;
  }
}
