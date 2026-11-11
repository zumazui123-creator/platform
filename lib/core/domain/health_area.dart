/// Die drei Hauptbereiche der Plattform.
///
/// Jeder Bereich besitzt eigene Daten, eigene Repositorys und ein eigenes
/// Dashboard mit individueller Konfiguration.
///
/// Bewusst framework-frei (keine Flutter-Imports): Domain-Schicht bleibt
/// rein Dart und damit unit-testbar ohne Widget-Test-Setup. Icons &
/// Labels fürs UI leben in der Presentation-Schicht (z. B.
/// features/navigation/area_icon.dart).
enum HealthArea {
  gesundheit,
  fitness,
  psychologie;

  /// Deutsche Anzeigebezeichnung.
  String get label => switch (this) {
    HealthArea.gesundheit => 'Gesundheit',
    HealthArea.fitness => 'Fitness',
    HealthArea.psychologie => 'Psychologie',
  };

  /// Kurzbeschreibung für UI-Texte.
  String get description => switch (this) {
    HealthArea.gesundheit => 'Messwerte, Statistiken und medizinische Daten',
    HealthArea.fitness => 'Training, Aktivität und Leistungsentwicklung',
    HealthArea.psychologie => 'Wohlbefinden, Stimmung, Stress und Schlaf',
  };

  /// Robustes Parsen (für JSON/DB-Werte).
  static HealthArea parse(String raw) {
    final normalized = raw.toLowerCase().trim();
    for (final area in values) {
      if (area.name == normalized || area.label.toLowerCase() == normalized) {
        return area;
      }
    }
    throw ArgumentError.value(raw, 'raw', 'Unbekannter HealthArea');
  }
}
