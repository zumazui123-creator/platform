import '../../core/domain/health_area.dart';

/// Statische Katalog-Definition einer Serie (App-Metadaten, kein
/// Benutzerdaten): welche Serien es pro Bereich gibt, wie sie heißen
/// und welche Einheit sie haben.
///
/// Die eigentlichen Messpunkte liegen in der Datenbank (bzw. in den
/// Demo-Daten) und werden von den Repositorys mit diesem Katalog zu
/// vollständigen [MetricSeries] kombiniert.
class SeriesDef {
  const SeriesDef({
    required this.id,
    required this.name,
    required this.unit,
    required this.area,
  });

  /// Stabile ID (wird von Dashboard-Props referenziert).
  final String id;
  final String name;
  final String unit;
  final HealthArea area;
}

/// Alle bekannten Serien der Plattform (Version 1 des Katalogs).
const List<SeriesDef> kSeriesCatalog = [
  // Gesundheit
  SeriesDef(
    id: 'health-weight',
    name: 'Körpergewicht',
    unit: 'kg',
    area: HealthArea.gesundheit,
  ),
  SeriesDef(
    id: 'health-systolic',
    name: 'Blutdruck systolisch',
    unit: 'mmHg',
    area: HealthArea.gesundheit,
  ),
  SeriesDef(
    id: 'health-glucose',
    name: 'Blutzucker (nüchtern)',
    unit: 'mg/dl',
    area: HealthArea.gesundheit,
  ),
  SeriesDef(
    id: 'health-resting-hr',
    name: 'Ruhepuls',
    unit: 'bpm',
    area: HealthArea.gesundheit,
  ),
  // Fitness
  SeriesDef(
    id: 'fitness-steps',
    name: 'Schritte/Tag',
    unit: 'Schritte',
    area: HealthArea.fitness,
  ),
  SeriesDef(
    id: 'fitness-calories',
    name: 'Verbrannte Kalorien',
    unit: 'kcal',
    area: HealthArea.fitness,
  ),
  SeriesDef(
    id: 'fitness-workout-min',
    name: 'Trainingsdauer',
    unit: 'min',
    area: HealthArea.fitness,
  ),
  SeriesDef(
    id: 'fitness-vo2max',
    name: 'VO₂max',
    unit: 'ml/kg/min',
    area: HealthArea.fitness,
  ),
  // Psychologie
  SeriesDef(
    id: 'psych-mood',
    name: 'Stimmung',
    unit: '1–10',
    area: HealthArea.psychologie,
  ),
  SeriesDef(
    id: 'psych-stress',
    name: 'Stresslevel',
    unit: '1–10',
    area: HealthArea.psychologie,
  ),
  SeriesDef(
    id: 'psych-sleep-h',
    name: 'Schlafdauer',
    unit: 'h',
    area: HealthArea.psychologie,
  ),
  SeriesDef(
    id: 'psych-sleep-quality',
    name: 'Schlafqualität',
    unit: '1–10',
    area: HealthArea.psychologie,
  ),
];
