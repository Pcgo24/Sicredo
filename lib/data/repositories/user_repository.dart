import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository for managing user data in Firestore
/// Handles CRUD operations for user documents
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get users collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Create or update a user document
  Future<void> setUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get a user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update user fields
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of user document (real-time updates)
  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }
}
