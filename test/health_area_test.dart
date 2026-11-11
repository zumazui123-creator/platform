import 'package:flutter_test/flutter_test.dart';
import 'package:health_platform/core/domain/health_area.dart';

void main() {
  group('HealthArea', () {
    test('labels sind korrekt', () {
      expect(HealthArea.gesundheit.label, 'Gesundheit');
      expect(HealthArea.fitness.label, 'Fitness');
      expect(HealthArea.psychologie.label, 'Psychologie');
    });

    test('parse akzeptiert Enum-Name und Label', () {
      expect(HealthArea.parse('gesundheit'), HealthArea.gesundheit);
      expect(HealthArea.parse('Gesundheit'), HealthArea.gesundheit);
      expect(HealthArea.parse(' fitness '), HealthArea.fitness);
    });

    test('parse wirft bei unbekanntem Wert', () {
      expect(() => HealthArea.parse('ernährung'), throwsArgumentError);
    });

    test('alle Bereiche haben eine Beschreibung', () {
      for (final area in HealthArea.values) {
        expect(area.description, isNotEmpty);
      }
    });
  });
}
