import 'package:cloud_firestore/cloud_firestore.dart';
import '../../pet.dart';

// This Repository handles all direct interactions with the "Cloud Data Storage"
// (Firebase Cloud Firestore).
class PetsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pets';

  /// Get real-time stream of all pets
  Stream<List<Pet>> getPetsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Pet.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get all pets as a one-time fetch
  Future<List<Pet>> getPets() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Pet.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch pets: $e');
    }
  }

  /// Get a single pet by ID
  Future<Pet?> getPetById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Pet.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch pet: $e');
    }
  }

  /// Add a new pet
  Future<String> addPet(Pet pet) async {
    try {
      final docRef = await _firestore.collection(_collection).add(pet.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add pet: $e');
    }
  }

  /// Update an existing pet
  Future<void> updatePet(String id, Pet pet) async {
    try {
      await _firestore.collection(_collection).doc(id).update(pet.toMap());
    } catch (e) {
      throw Exception('Failed to update pet: $e');
    }
  }

  /// Delete a pet
  Future<void> deletePet(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete pet: $e');
    }
  }

  /// Search pets by breed
  Future<List<Pet>> searchPetsByBreed(String breed) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('breed', isEqualTo: breed)
          .get();

      return snapshot.docs.map((doc) {
        return Pet.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search pets: $e');
    }
  }

  /// Get pets by location (requires proper geohashing for real app)
  Stream<List<Pet>> getPetsByLocation(double lat, double lng, double radiusKm) {
    // For simplicity, getting all pets
    // In production, implement geohashing/geofire for proper location queries
    return getPetsStream();
  }
}
