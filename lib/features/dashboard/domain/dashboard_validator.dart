import '../../../core/domain/health_area.dart';
import '../../../core/errors.dart';
import 'dashboard_schema.dart';

/// Statische Validierung von Dashboard-Layouts.
///
/// Regelwerk (fail-closed):
/// - `schemaVersion` muss [kDashboardSchemaVersion] sein
/// - `name` nicht leer, `area` bekannt
/// - `widgets`: Indexe eindeutig und aufsteigend ab 0
/// - `type` nur aus [WidgetType]
/// - `size`: 1 ≤ cols ≤ 4, 1 ≤ rows ≤ 3
/// - `props`: nur erlaubte Keys; bekannte Werte korrekt getypt
///
/// Der Validator ist der einzige Ort, der ein Layout "gültig" erklärt —
/// Editor, Store, Repository und AI-Tools müssen ihn durchlaufen.
class DashboardValidator {
  const DashboardValidator._();

  /// Maximale Anzahl Bausteine pro Layout (Schutz vor Speichergewalt).
  static const int maxWidgets = 24;

  /// Ermittelt alle Validierungsfehler (leere Liste = gültig).
  static List<String> validate(DashboardLayout layout) {
    final errors = <String>[];
    if (layout.schemaVersion != kDashboardSchemaVersion) {
      errors.add(
        'Schema-Version ${layout.schemaVersion} wird nicht unterstützt (erwartet $kDashboardSchemaVersion).',
      );
    }
    if (layout.name.trim().isEmpty) {
      errors.add('Layout-Name darf nicht leer sein.');
    }
    _validateArea(layout.area, errors);
    if (layout.widgets.length > maxWidgets) {
      errors.add('Maximal $maxWidgets Bausteine pro Layout.');
    }
    var expectedIndex = 0;
    for (final w in layout.widgets) {
      if (w.index != expectedIndex) {
        errors.add(
          'Baustein-Indexe müssen 0-basiert und lückenlos sein '
          '(Baustein ${w.id} hat Index ${w.index}, erwartet $expectedIndex).',
        );
      }
      expectedIndex++;
      _validateWidget(w, errors);
    }
    return errors;
  }

  /// Wirft [ValidationException] mit allen Fehlern, falls ungültig.
  static void ensureValid(DashboardLayout layout) {
    final errors = validate(layout);
    if (errors.isNotEmpty) {
      throw ValidationException(
        'Ungültiges Dashboard-Layout: ${errors.join(' ')}',
      );
    }
  }

  /// Validiert nur die props eines Bausteins (wird auch für
  /// KI-generierte Einzel-Konfigurationen genutzt).
  static List<String> validateProps(
    WidgetType type,
    Map<String, Object?> props,
  ) {
    final errors = <String>[];
    final allowed = _allowedProps(type);
    props.forEach((key, value) {
      if (!allowed.containsKey(key)) {
        errors.add('Nicht erlaubtes Property "$key" für ${type.label}.');
        return;
      }
      final ok = switch (allowed[key]!) {
        'seriesId' => value is String && value.trim().isNotEmpty,
        'title' => value is String,
        'target' => value is num && value.toDouble() > 0,
        'rows' => value is int && value >= 1 && value <= 20,
        _ => false,
      };
      if (!ok) {
        errors.add('Property "$key" hat einen ungültigen Wert: $value');
      }
    });
    return errors;
  }

  /// Sanisiert Props: behält nur erlaubte Keys, wirft den Rest weg.
  static Map<String, Object?> sanitizeProps(
    WidgetType type,
    Map<String, Object?> props,
  ) {
    final allowed = _allowedProps(type);
    final out = <String, Object?>{};
    props.forEach((key, value) {
      if (allowed.containsKey(key)) out[key] = value;
    });
    return out;
  }

  static void _validateArea(HealthArea area, List<String> errors) {
    // HealthArea ist ein Enum → per Definition gültig; bleibt als
    // Anker für spätere Multi-Tenant-/Bereichs-Erweiterungen.
  }

  static void _validateWidget(WidgetConfig w, List<String> errors) {
    if (w.id.isEmpty) {
      errors.add('Baustein-ID darf nicht leer sein.');
      return;
    }
    if (w.size.cols < 1 || w.size.cols > 4) {
      errors.add(
        'Baustein ${w.id}: Breite muss 1–4 sein (ist ${w.size.cols}).',
      );
    }
    if (w.size.rows < 1 || w.size.rows > 3) {
      errors.add('Baustein ${w.id}: Höhe muss 1–3 sein (ist ${w.size.rows}).');
    }
    errors.addAll(validateProps(w.type, w.props));
  }

  /// Erlaubte Props pro Typ: key → erwartete Beschreibungs-Klasse.
  static Map<String, String> _allowedProps(WidgetType type) {
    final base = {'seriesId': 'seriesId', 'title': 'title'};
    final extra = switch (type) {
      WidgetType.progress => {'target': 'target'},
      WidgetType.table => {'rows': 'rows'},
      _ => const <String, String>{},
    };
    return {...base, ...extra};
  }
}
