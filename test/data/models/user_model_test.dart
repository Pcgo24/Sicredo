import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sicredo/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel correctly', () {
      final timestamp = Timestamp.now();
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: timestamp,
      );

      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.createdAt, timestamp);
    });

    test('toMap should convert UserModel to Map correctly', () {
      final timestamp = Timestamp.now();
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: timestamp,
      );

      final map = user.toMap();

      expect(map['uid'], 'user123');
      expect(map['email'], 'test@example.com');
      expect(map['displayName'], 'Test User');
      expect(map['createdAt'], timestamp);
    });

    test('copyWith should create a copy with updated fields', () {
      final timestamp = Timestamp.now();
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: timestamp,
      );

      final updated = user.copyWith(
        displayName: 'Updated Name',
        email: 'newemail@example.com',
      );

      expect(updated.uid, 'user123');
      expect(updated.email, 'newemail@example.com');
      expect(updated.displayName, 'Updated Name');
      expect(updated.createdAt, timestamp);
    });

    test('should handle null displayName', () {
      final timestamp = Timestamp.now();
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: null,
        createdAt: timestamp,
      );

      expect(user.displayName, isNull);
      
      final map = user.toMap();
      expect(map['displayName'], isNull);
    });
  });
}
