import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing app users
// This class defines the data structure for Users, corresponding to the
// 'users' collection in the Firestore database.
class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phone;
  final DateTime? createdAt;
  final List<String>? reportedPetIds; // IDs of pets reported by this user
  final String? username; // Unique username handle
  final String role; // 'user', 'admin', 'banned'

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.username,
    this.photoUrl,
    this.phone,
    this.createdAt,
    this.reportedPetIds,
    this.role = 'user',
  });

  /// Convert User to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'username': username,
      'photoUrl': photoUrl,
      'phone': phone,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'reportedPetIds': reportedPetIds ?? [],
      'role': role,
    };
  }

  /// Create User from Firestore document
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      uid: documentId,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      username: map['username'],
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      reportedPetIds: map['reportedPetIds'] != null
          ? List<String>.from(map['reportedPetIds'])
          : null,
      role: map['role'] ?? 'user',
    );
  }

  /// Create a copy with updated fields
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? photoUrl,
    String? phone,
    DateTime? createdAt,
    List<String>? reportedPetIds,
    String? role,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      reportedPetIds: reportedPetIds ?? this.reportedPetIds,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'User{uid: $uid, email: $email, displayName: $displayName, username: $username, role: $role}';
  }
}
