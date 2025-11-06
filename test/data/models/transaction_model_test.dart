import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('TransactionModel', () {
    test('toMap should convert model to Map correctly for Firestore', () {
      final transaction = TransactionModel(
        id: 'test-id-1',
        nome: 'Salário',
        valor: 5000.0,
        data: DateTime(2024, 1, 15),
        isGanho: true,
      );

      final map = transaction.toMap();

      // Note: id is not included in toMap() for Firestore
      expect(map.containsKey('id'), false);
      expect(map['nome'], 'Salário');
      expect(map['valor'], 5000.0);
      expect(map['data'], isA<Timestamp>());
      expect((map['data'] as Timestamp).toDate(), DateTime(2024, 1, 15));
      expect(map['isGanho'], true);
    });

    test('fromMap should create model from Map with int data (backward compatibility)', () {
      final map = {
        'nome': 'Mercado',
        'valor': 250.5,
        'data': DateTime(2024, 1, 20).millisecondsSinceEpoch,
        'isGanho': 0,
      };

      final transaction = TransactionModel.fromMap(map, id: 'test-id-2');

      expect(transaction.id, 'test-id-2');
      expect(transaction.nome, 'Mercado');
      expect(transaction.valor, 250.5);
      expect(transaction.data, DateTime(2024, 1, 20));
      expect(transaction.isGanho, false);
    });

    test('fromMap should create model from Map with Timestamp', () {
      final map = {
        'nome': 'Mercado',
        'valor': 250.5,
        'data': Timestamp.fromDate(DateTime(2024, 1, 20)),
        'isGanho': true,
      };

      final transaction = TransactionModel.fromMap(map, id: 'test-id-3');

      expect(transaction.id, 'test-id-3');
      expect(transaction.nome, 'Mercado');
      expect(transaction.valor, 250.5);
      expect(transaction.data, DateTime(2024, 1, 20));
      expect(transaction.isGanho, true);
    });

    test('copyWith should create a copy with updated fields', () {
      final transaction = TransactionModel(
        id: 'test-id-4',
        nome: 'Original',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final updated = transaction.copyWith(
        nome: 'Updated',
        valor: 200.0,
      );

      expect(updated.id, 'test-id-4');
      expect(updated.nome, 'Updated');
      expect(updated.valor, 200.0);
      expect(updated.data, DateTime(2024, 1, 1));
      expect(updated.isGanho, true);
    });

    test('equality should work correctly', () {
      final transaction1 = TransactionModel(
        id: 'test-id-5',
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final transaction2 = TransactionModel(
        id: 'test-id-5',
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final transaction3 = TransactionModel(
        id: 'test-id-6',
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      expect(transaction1, equals(transaction2));
      expect(transaction1, isNot(equals(transaction3)));
    });

    test('hashCode should be consistent', () {
      final transaction1 = TransactionModel(
        id: 'test-id-7',
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final transaction2 = TransactionModel(
        id: 'test-id-7',
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      expect(transaction1.hashCode, equals(transaction2.hashCode));
    });

    test('isGanho should be handled correctly in toMap', () {
      final ganho = TransactionModel(
        nome: 'Ganho',
        valor: 100.0,
        data: DateTime.now(),
        isGanho: true,
      );

      final gasto = TransactionModel(
        nome: 'Gasto',
        valor: 50.0,
        data: DateTime.now(),
        isGanho: false,
      );

      expect(ganho.toMap()['isGanho'], true);
      expect(gasto.toMap()['isGanho'], false);
    });
  });
}
