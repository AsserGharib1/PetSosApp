import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'package:app/models/data/repositories/pets_repository.dart';
import 'package:app/models/data/services/storage_service.dart';
import 'dart:async';
import 'dart:io';

// This ViewModel manages the State of the View and communicates with the Model.
// It implements the "ViewModel" part of the MVVM pattern.
class PetsViewModel extends ChangeNotifier {
  final PetsRepository _repository;
  final StorageService _storageService;
  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _petsSubscription;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Dependency Injection of the Repository (Model)
  PetsViewModel({PetsRepository? repository, StorageService? storageService})
      : _repository = repository ?? PetsRepository(),
        _storageService = storageService ?? StorageService();

  /// Load pets with real-time updates
  void loadPets() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Cancel previous subscription if exists
    _petsSubscription?.cancel();

    // Listen to real-time updates from Firestore
    _petsSubscription = _repository.getPetsStream().listen(
      (pets) {
        _pets = pets;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error loading pets: $error');
        _errorMessage = _parseError(error);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Upload pet image
  Future<String?> uploadPetImage(File imageFile) async {
    return await _storageService.uploadImage(imageFile);
  }

  /// Add a new pet
  Future<bool> addPet(Pet pet, {File? imageFile}) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      String? imageUrl = pet.imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        try {
          imageUrl = await uploadPetImage(imageFile);
        } catch (e) {
          debugPrint('Image upload failed: $e');

          imageUrl = null;
        }
      }

      final petToSave = pet.copyWith(imageUrl: imageUrl);

      await _repository.addPet(petToSave);

      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint('Error adding pet: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing pet
  Future<bool> updatePet(String id, Pet pet) async {
    try {
      _errorMessage = null;
      await _repository.updatePet(id, pet);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint('Error updating pet: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a pet
  Future<bool> deletePet(String id) async {
    try {
      _errorMessage = null;
      await _repository.deletePet(id);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint('Error deleting pet: $e');
      notifyListeners();
      return false;
    }
  }

  /// Search pets by breed
  Future<void> searchByBreed(String breed) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pets = await _repository.searchPetsByBreed(breed);
    } catch (e) {
      _errorMessage = _parseError(e);
      debugPrint('Error searching pets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Parse error messages to be user-friendly
  // This method catches low-level technical errors and converts them into
  // user-friendly messages for the UI.
  String _parseError(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'Database access denied. Please enable Firestore in Firebase Console.';
    } else if (errorStr.contains('not found')) {
      return 'Item not found';
    } else if (errorStr.contains('object-not-found')) {
      return 'Storage Bucket not found. Please enable Storage in Firebase Console.';
    } else if (errorStr.contains('network')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An error occurred. Please try again.\n($error)';
    }
  }

  /// Initialize with demo data if needed (for testing)
  Future<void> initDemoData() async {
    // Start listening to real-time data
    loadPets();

    // Optionally add demo data if collection is empty
    // This can be removed in production
    if (_pets.isEmpty) {
      debugPrint(
        'No pets found. Database might be empty or permissions issue.',
      );
    }
  }

  @override
  void dispose() {
    _petsSubscription?.cancel();
    super.dispose();
  }
}
