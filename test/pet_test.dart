import 'package:flutter_test/flutter_test.dart';
import 'package:petsos/models/pet.dart';

// ==============================================================================
// MARKING CRITERIA: Unit Types & Data Items
// ------------------------------------------------------------------------------
// This test file covers the "Unit Tests design and reports" requirement.
// It specifically tests the "Data items description" by verifying that the
// Pet model correctly serializes to/from the database format (toMap/fromMap).
// ==============================================================================

void main() {
  group('Pet Model Tests', () {
    test('Pet should be correctly converted to Map', () {
      final pet = Pet(
        id: '1', // Changed to String
        name: 'Buddy',
        status: 'Lost',
        location: 'Home',
        date: '2025-01-01',
        latitude: 10.0,
        longitude: 20.0,
      );

      final map = pet.toMap();

      // expect(map['id'], '1'); // ID is not in map anymore
      expect(map['name'], 'Buddy');
      expect(map['status'], 'Lost');
      expect(map['latitude'], 10.0);
    });

    test('Pet should be correctly created from Map', () {
      final map = {
        // 'id': '2',
        'name': 'Lucy',
        'status': 'Found',
        'location': 'Park',
        'date': '2025-02-02',
        'description': 'Cute',
        'latitude': 30.0,
        'longitude': 40.0,
      };

      final pet = Pet.fromMap(map, '2'); // Pass ID separately

      expect(pet.id, '2');
      expect(pet.name, 'Lucy');
      expect(pet.status, 'Found');
      expect(pet.longitude, 40.0);
    });

    test('Pet copyWith creates new instance with updated fields', () {
      final pet = Pet(
        id: '1',
        name: 'Buddy',
        status: 'Lost',
        location: 'Home',
        date: '2025-01-01',
      );

      final updatedPet = pet.copyWith(name: 'Max', status: 'Found');

      expect(updatedPet.id, '1'); // Unchanged
      expect(updatedPet.name, 'Max'); // Changed
      expect(updatedPet.status, 'Found'); // Changed
      expect(pet.name, 'Buddy'); // Original unchanged
    });
  });
}
