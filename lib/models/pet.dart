import 'package:cloud_firestore/cloud_firestore.dart';

// This class defines the "Data Structure" for the Pet node.
// It includes all required fields mapped to correct data types (String, double, etc).
class Pet {
  final String? id;
  final String name;
  final String status; // 'Lost' or 'Found'
  final String location;
  final String date;
  final String description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String? ownerId;
  final DateTime? timestamp;
  final String? breed;
  final String? petType; // 'Dog', 'Cat', 'Other'
  final String? color;
  final String? size; // 'Small', 'Medium', 'Large'
  final String? gender; // 'Male', 'Female', 'Unknown'
  final String? contactInfo; // Phone or email to contact owner

  Pet({
    this.id,
    required this.name,
    required this.status,
    required this.location,
    required this.date,
    this.description = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.imageUrl,
    this.ownerId,
    this.timestamp,
    this.breed,
    this.petType,
    this.color,
    this.size,
    this.gender,
    this.contactInfo,
  });

  // Serialization methods (toMap/fromMap) to handle data persistence
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'location': location,
      'date': date,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
      'breed': breed,
      'petType': petType,
      'color': color,
      'size': size,
      'gender': gender,
      'contactInfo': contactInfo,
    };
  }

  /// Create a Pet from Firestore document
  factory Pet.fromMap(Map<String, dynamic> map, String documentId) {
    return Pet(
      id: documentId,
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      location: map['location'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      breed: map['breed'],
      petType: map['petType'],
      color: map['color'],
      size: map['size'],
      gender: map['gender'],
      contactInfo: map['contactInfo'],
    );
  }

  /// Create a copy with updated fields
  Pet copyWith({
    String? id,
    String? name,
    String? status,
    String? location,
    String? date,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
    String? ownerId,
    DateTime? timestamp,
    String? breed,
    String? petType,
    String? color,
    String? size,
    String? gender,
    String? contactInfo,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      location: location ?? this.location,
      date: date ?? this.date,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      timestamp: timestamp ?? this.timestamp,
      breed: breed ?? this.breed,
      petType: petType ?? this.petType,
      color: color ?? this.color,
      size: size ?? this.size,
      gender: gender ?? this.gender,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  @override
  String toString() {
    return 'Pet{id: $id, name: $name, status: $status, location: $location, date: $date}';
  }
}
