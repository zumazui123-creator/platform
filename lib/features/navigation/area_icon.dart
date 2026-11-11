import 'package:flutter/material.dart';

import '../../core/domain/health_area.dart';

/// Icon pro Hauptbereich (Presentation-Layer — die Domain bleibt rein Dart).
Icon iconForArea(HealthArea area) => switch (area) {
  HealthArea.gesundheit => const Icon(Icons.monitor_heart_outlined),
  HealthArea.fitness => const Icon(Icons.fitness_center_outlined),
  HealthArea.psychologie => const Icon(Icons.self_improvement_outlined),
};
