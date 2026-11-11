import 'dart:convert';

import '../../../core/domain/health_area.dart';
import '../../../core/errors.dart';
import 'dashboard_schema.dart';
import 'dashboard_validator.dart';

/// Strikte, handgeschriebene JSON-Kodierung des Dashboard-Schemas.
///
/// Sicherheitsprinzip: Konfigurationen sind reine Daten. Dieses Modul
/// akzeptiert nur das versionierte Schema, lehnt fremde Typen/Versionen
/// ab und wirft den Rest weg — es kann niemals Code auslösen.
///
/// Alle Ein-/Ausgänge des Systems (Repository, Editor, AI-Tools) gehen
/// durch [parseLayout] / [layoutToJson].

/// Wandelt ein valides [DashboardLayout] in JSON (Map) um.
Map<String, dynamic> layoutToJson(DashboardLayout layout) => {
  'schemaVersion': layout.schemaVersion,
  'id': layout.id,
  'name': layout.name,
  'area': layout.area.name,
  'widgets': [for (final w in layout.widgets) widgetConfigToJson(w)],
};

/// Serialisiert ein Layout als JSON-String (für Repository/Storage).
String layoutToJsonString(DashboardLayout layout) =>
    const JsonEncoder.withIndent('  ').convert(layoutToJson(layout));

/// Parst ein Layout aus einem JSON-String.
///
/// Wirft [ValidationException] bei strukturellen Fehlern.
DashboardLayout parseLayoutString(String raw) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException catch (e) {
    throw ValidationException('Layout ist kein gültiges JSON: $e');
  }
  if (decoded is! Map<String, dynamic>) {
    throw ValidationException(
      'Layout-Wurzelelement muss ein JSON-Object sein.',
    );
  }
  final layout = parseLayout(decoded);
  // Fail-closed an der Trust-Boundary: jedes eintreffende Layout wird
  // zusätzlich semantisch validiert (Größen, Props, Indizes).
  DashboardValidator.ensureValid(layout);
  return layout;
}

/// Parst ein Layout aus einem JSON-Objekt (strikt, fail-closed).
DashboardLayout parseLayout(Map<String, dynamic> json) {
  final version = (json['schemaVersion'] as num?)?.toInt();
  if (version == null || version != kDashboardSchemaVersion) {
    throw ValidationException(
      'Nicht unterstützte Schema-Version: $version (erwartet $kDashboardSchemaVersion).',
    );
  }
  final area = _parseArea(json['area']);
  final widgets = <WidgetConfig>[];
  final rawWidgets = json['widgets'];
  if (rawWidgets is List) {
    for (var i = 0; i < rawWidgets.length; i++) {
      final item = rawWidgets[i];
      if (item is! Map<String, dynamic>) {
        throw ValidationException('Baustein $i ist kein JSON-Object.');
      }
      widgets.add(_parseWidget(item, i));
    }
  }
  return DashboardLayout(
    schemaVersion: version,
    id: _requireString(json['id'], 'id'),
    name: _requireString(json['name'], 'name'),
    area: area,
    widgets: widgets,
  );
}

Map<String, dynamic> widgetConfigToJson(WidgetConfig w) => {
  'id': w.id,
  'type': w.type.name,
  'index': w.index,
  'size': {'cols': w.size.cols, 'rows': w.size.rows},
  'props': w.props,
};

WidgetConfig _parseWidget(Map<String, dynamic> json, int expectedIndex) {
  final type = _parseWidgetType(json['type']);
  final sizeJson = json['size'];
  final cols = sizeJson is Map<String, dynamic>
      ? (sizeJson['cols'] as num?)?.toInt()
      : null;
  final rows = sizeJson is Map<String, dynamic>
      ? (sizeJson['rows'] as num?)?.toInt()
      : null;
  final propsJson = json['props'];
  final props = <String, Object?>{
    if (propsJson is Map)
      for (final e in propsJson.entries)
        if (e.value is String ||
            e.value is num ||
            e.value is bool ||
            e.value == null)
          e.key: e.value,
  };
  return WidgetConfig(
    id: _requireString(json['id'], 'widget.id[$expectedIndex]'),
    type: type,
    index: (json['index'] as num?)?.toInt() ?? expectedIndex,
    size: WidgetSize(cols: cols ?? 2, rows: rows ?? 2),
    props: props,
  );
}

HealthArea _parseArea(Object? raw) {
  try {
    return HealthArea.parse(_requireString(raw, 'area'));
  } on ArgumentError {
    throw ValidationException('Unbekannter Bereich: $raw');
  }
}

WidgetType _parseWidgetType(Object? raw) {
  final s = _requireString(raw, 'type');
  for (final t in WidgetType.values) {
    if (t.name == s) return t;
  }
  throw ValidationException('Nicht erlaubter Baustein-Typ: "$s"');
}

String _requireString(Object? raw, String field) {
  if (raw is! String || raw.trim().isEmpty) {
    throw ValidationException('Feld "$field" fehlt oder ist leer.');
  }
  return raw;
}
