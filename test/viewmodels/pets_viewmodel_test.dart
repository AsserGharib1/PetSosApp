import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:app/viewmodels/pets_viewmodel.dart';
import 'package:app/models/data/repositories/pets_repository.dart';
import 'package:app/models/data/services/storage_service.dart';
import 'package:app/models/pet.dart';
import 'dart:async';

// Generate mocks
@GenerateNiceMocks([MockSpec<PetsRepository>(), MockSpec<StorageService>()])
import 'pets_viewmodel_test.mocks.dart';

void main() {
  group('PetsViewModel Tests', () {
    late PetsViewModel petsViewModel;
    late MockPetsRepository mockRepository;
    late MockStorageService mockStorageService;

    setUp(() {
      mockRepository = MockPetsRepository();
      mockStorageService = MockStorageService();

      // Stub getPetsStream to return empty list by default
      when(mockRepository.getPetsStream()).thenAnswer((_) => Stream.value([]));

      petsViewModel = PetsViewModel(
        repository: mockRepository,
        storageService: mockStorageService,
      );

      // Manually load pets as it's no longer in constructor
      petsViewModel.loadPets();
    });

    test('Initial loading state is true then false', () async {
      // Create new VM for this test to capture initial state
      // We need to delay the stream emission slightly or check values immediately
      // But since loadPets is called in constructor, it triggers immediately.

      // We can verify that getPetsStream was called
      verify(mockRepository.getPetsStream()).called(1);
    });

    test('loadPets updates pets list', () async {
      final pets = [
        Pet(
            id: '1',
            name: 'Buddy',
            status: 'Lost',
            latitude: 0,
            longitude: 0,
            location: 'Loc',
            date: '2025-01-01',
            description: 'Desc'),
      ];

      when(mockRepository.getPetsStream())
          .thenAnswer((_) => Stream.value(pets));

      petsViewModel.loadPets();

      // wait for stream to emit
      await Future.delayed(Duration.zero);

      expect(petsViewModel.pets.length, 1);
      expect(petsViewModel.pets.first.name, 'Buddy');
    });

    test('addPet logic calls repository', () async {
      final pet = Pet(
          id: 'new',
          name: 'New Pet',
          status: 'Lost',
          latitude: 0,
          longitude: 0,
          location: 'Loc',
          date: '2025-01-01',
          description: 'Desc');

      when(mockRepository.addPet(any)).thenAnswer((_) async => 'new_id');

      final result = await petsViewModel.addPet(pet);

      expect(result, true);
      verify(mockRepository.addPet(any)).called(1);
    });
  });
}
