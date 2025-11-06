import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sicredo/data/repositories/user_repository.dart';
import 'package:sicredo/data/models/user_model.dart';

void main() {
  group('UserRepository', () {
    late UserRepository repository;

    setUp(() {
      repository = UserRepository();
    });

    test('should have methods for CRUD operations', () {
      expect(repository.setUser, isA<Function>());
      expect(repository.getUser, isA<Function>());
      expect(repository.updateUser, isA<Function>());
      expect(repository.deleteUser, isA<Function>());
      expect(repository.userExists, isA<Function>());
    });

    test('UserModel should be created correctly', () {
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: Timestamp.now(),
      );

      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.createdAt, isA<Timestamp>());
    });

    test('UserModel toMap should work correctly', () {
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: Timestamp.now(),
      );

      final map = user.toMap();

      expect(map['uid'], 'user123');
      expect(map['email'], 'test@example.com');
      expect(map['displayName'], 'Test User');
      expect(map['createdAt'], isA<Timestamp>());
    });

    test('getUserStream should return Stream<UserModel?>', () {
      final stream = repository.getUserStream('user123');
      expect(stream, isA<Stream<UserModel?>>());
    });
  });
}
