import 'package:flutter_test/flutter_test.dart';
import 'package:app/viewmodels/map_viewmodel.dart';
import 'package:app/models/pet.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('MapViewModel Tests', () {
    late MapViewModel mapViewModel;

    setUp(() {
      mapViewModel = MapViewModel();
    });

    test('Initial state is correct', () {
      expect(mapViewModel.filterStatus, 'All');
      expect(mapViewModel.selectedPet, null);
      expect(mapViewModel.zoomLevel, 13.0);
    });

    test('setFilterStatus updates status correctly', () {
      mapViewModel.setFilterStatus('Lost');
      expect(mapViewModel.filterStatus, 'Lost');

      mapViewModel.setFilterStatus('Found');
      expect(mapViewModel.filterStatus, 'Found');

      // Invalid status should not change anything
      mapViewModel.setFilterStatus('Invalid');
      expect(mapViewModel.filterStatus, 'Found');
    });

    test('filterPets returns correct list based on status', () {
      final pets = [
        Pet(
          id: '1',
          name: 'Buddy',
          status: 'Lost',
          latitude: 0,
          longitude: 0,
          location: 'Loc1',
          date: '2025-01-01',
          description: 'Desc',
        ),
        Pet(
          id: '2',
          name: 'Kitty',
          status: 'Found',
          latitude: 0,
          longitude: 0,
          location: 'Loc2',
          date: '2025-01-01',
          description: 'Desc',
        ),
      ];

      // Test All
      mapViewModel.setFilterStatus('All');
      final allPets = mapViewModel.filterPets(pets);
      expect(allPets.length, 2);

      // Test Lost
      mapViewModel.setFilterStatus('Lost');
      final lostPets = mapViewModel.filterPets(pets);
      expect(lostPets.length, 1);
      expect(lostPets.first.name, 'Buddy');

      // Test Found
      mapViewModel.setFilterStatus('Found');
      final foundPets = mapViewModel.filterPets(pets);
      expect(foundPets.length, 1);
      expect(foundPets.first.name, 'Kitty');
    });

    test('selectPet updates selectedPet and mapCenter', () {
      final pet = Pet(
        id: '1',
        name: 'Buddy',
        status: 'Lost',
        latitude: 10.0,
        longitude: 20.0,
        location: 'Loc1',
        date: '2025-01-01',
        description: 'Desc',
      );

      mapViewModel.selectPet(pet);

      expect(mapViewModel.selectedPet, pet);
      expect(mapViewModel.mapCenter, LatLng(10.0, 20.0));
    });

    test('Zoom in/out logic works within bounds', () {
      // Zoom out
      mapViewModel.setZoomLevel(2.0);
      mapViewModel.zoomOut();
      expect(mapViewModel.zoomLevel, 1.0);
      mapViewModel.zoomOut(); // Should not go below 1.0
      expect(mapViewModel.zoomLevel, 1.0);

      // Zoom in
      mapViewModel.setZoomLevel(17.0);
      mapViewModel.zoomIn();
      expect(mapViewModel.zoomLevel, 18.0);
      mapViewModel.zoomIn(); // Should not go above 18.0
      expect(mapViewModel.zoomLevel, 18.0);
    });
  });
}
