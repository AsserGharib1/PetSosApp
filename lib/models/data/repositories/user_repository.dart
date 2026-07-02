import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../user.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final String _collection = 'users';

  /// Get current user's profile
  Future<User?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection(_collection).doc(user.uid).get();
      if (!doc.exists) return null;
      return User.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Create or update user profile
  Future<void> saveUserProfile({
    required String
        name, // Keeps parameter name for compatibility, but maps to displayName
    String? username,
    String? phone,
    String? address,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      final data = {
        'displayName': name,
        if (username != null) 'username': username,
        'email': user.email,
        'phone': phone,
        'address': address,
        'photoUrl': photoUrl ?? user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Initialize user profile on first sign-in
  Future<void> initializeUserProfile(firebase.User user,
      {String? username, String? phone}) async {
    try {
      final doc = await _firestore.collection(_collection).doc(user.uid).get();

      // Only create if doesn't exist
      if (!doc.exists) {
        await _firestore.collection(_collection).doc(user.uid).set({
          'displayName': user.displayName ?? 'Anonymous User',
          'username': username,
          'email': user.email,
          'phone': phone,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });
      }
    } catch (e) {
      throw Exception('Failed to initialize user profile: $e');
    }
  }

  /// Update user's display name
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      await user.updateDisplayName(name);
      await _firestore.collection(_collection).doc(user.uid).update({
        'displayName': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  /// Get user by ID (for viewing other user profiles)
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (!doc.exists) return null;
      return User.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Get stream of all users (for admin)
  Stream<List<User>> getAllUsers() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => User.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Ban user by setting role to 'banned'
  Future<void> banUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'role': 'banned',
      });
    } catch (e) {
      throw Exception('Failed to ban user: $e');
    }
  }

  /// Unban user
  Future<void> unbanUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'role': 'user',
      });
    } catch (e) {
      throw Exception('Failed to unban user: $e');
    }
  }

  /// Update user's role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }
}
