import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../core/errors.dart';
import '../domain/dashboard_schema.dart';
import '../domain/schema_json.dart';
import 'dashboard_repository.dart';

/// Supabase-Persistenz für Dashboard-Layouts.
///
/// Tabelle `dashboard_layouts` (Schema siehe supabase/migrations):
/// ```
/// id text pk, user_id uuid not null references auth.users,
/// tenant_id uuid not null default personal_tenant_id(),
/// name text not null, area text not null, layout jsonb not null,
/// updated_at timestamptz default now()
/// ```
/// RLS: Nur der owning User (bzw. später das owning Team) kann
/// lesen/schreiben. Der Service-Role-Key liegt nie im Client.
class SupabaseDashboardRepository implements DashboardRepository {
  SupabaseDashboardRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'dashboard_layouts';

  @override
  bool get isDemo => false;

  @override
  Future<List<DashboardLayout>> listAll() async {
    final uid = _requireUser();
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .order('updated_at', ascending: true);
    return _rowsToLayouts(rows);
  }

  @override
  Future<DashboardLayout?> load(String id) async {
    final uid = _requireUser();
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', uid)
        .eq('id', id)
        .limit(1);
    final layouts = _rowsToLayouts(rows);
    return layouts.isEmpty ? null : layouts.first;
  }

  @override
  Future<void> save(DashboardLayout layout) async {
    final uid = _requireUser();
    final result = await _client.from(_table).upsert({
      'id': layout.id,
      'user_id': uid,
      'name': layout.name,
      'area': layout.area.name,
      'layout': layoutToJson(layout),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
    if (result == null) {
      throw NetworkException('Layout konnte nicht gespeichert werden.');
    }
  }

  @override
  Future<void> delete(String id) async {
    final uid = _requireUser();
    await _client.from(_table).delete().eq('user_id', uid).eq('id', id);
  }

  String _requireUser() {
    final session = _client.auth.currentSession;
    if (session == null) {
      throw AuthException('Keine aktive Session — Layouts sind geschützt.');
    }
    return session.user.id;
  }

  List<DashboardLayout> _rowsToLayouts(List<dynamic> rows) {
    final out = <DashboardLayout>[];
    for (final row in rows) {
      if (row is! Map) continue;
      try {
        final layoutJson = row['layout'];
        if (layoutJson is! Map) continue;
        // jsonb kommt bereits als Map; Keys sind Strings.
        final normalized = <String, dynamic>{
          for (final e in layoutJson.entries) e.key.toString(): e.value,
        };
        out.add(parseLayout(normalized));
      } on AppException {
        // Ungültige Zeilen überspringen (fail-safe, keine App-Crash).
      }
    }
    return out;
  }
}
