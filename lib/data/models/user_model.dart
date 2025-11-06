import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for Firestore
/// Represents a user in the users collection
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
  });

  /// Creates a UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  /// Converts UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt,
    };
  }

  /// Creates a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
