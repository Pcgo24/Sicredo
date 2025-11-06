import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/data/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    test('toMap should convert model to Map correctly', () {
      final transaction = TransactionModel(
        id: 1,
        nome: 'Salário',
        valor: 5000.0,
        data: DateTime(2024, 1, 15),
        isGanho: true,
      );

      final map = transaction.toMap();

      expect(map['id'], 1);
      expect(map['nome'], 'Salário');
      expect(map['valor'], 5000.0);
      expect(map['data'], DateTime(2024, 1, 15).millisecondsSinceEpoch);
      expect(map['isGanho'], 1);
    });

    test('fromMap should create model from Map correctly', () {
      final map = {
        'id': 1,
        'nome': 'Mercado',
        'valor': 250.5,
        'data': DateTime(2024, 1, 20).millisecondsSinceEpoch,
        'isGanho': 0,
      };

      final transaction = TransactionModel.fromMap(map);

      expect(transaction.id, 1);
      expect(transaction.nome, 'Mercado');
      expect(transaction.valor, 250.5);
      expect(transaction.data, DateTime(2024, 1, 20));
      expect(transaction.isGanho, false);
    });

    test('copyWith should create a copy with updated fields', () {
      final transaction = TransactionModel(
        id: 1,
        nome: 'Original',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final updated = transaction.copyWith(
        nome: 'Updated',
        valor: 200.0,
      );

      expect(updated.id, 1);
      expect(updated.nome, 'Updated');
      expect(updated.valor, 200.0);
      expect(updated.data, DateTime(2024, 1, 1));
      expect(updated.isGanho, true);
    });

    test('equality should work correctly', () {
      final transaction1 = TransactionModel(
        id: 1,
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final transaction2 = TransactionModel(
        id: 1,
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final transaction3 = TransactionModel(
        id: 2,
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
        id: 1,
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final transaction2 = TransactionModel(
        id: 1,
        nome: 'Test',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      expect(transaction1.hashCode, equals(transaction2.hashCode));
    });

    test('isGanho should be converted correctly to/from Map', () {
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

      expect(ganho.toMap()['isGanho'], 1);
      expect(gasto.toMap()['isGanho'], 0);
      
      expect(TransactionModel.fromMap(ganho.toMap()).isGanho, true);
      expect(TransactionModel.fromMap(gasto.toMap()).isGanho, false);
    });
  });
}
