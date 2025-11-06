import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sicredo/data/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    test('fromReais should create model correctly', () {
      final transaction = TransactionModel.fromReais(
        userId: 'user123',
        nome: 'Salário',
        valor: 5000.0,
        dataTime: DateTime(2024, 1, 15),
        isGanho: true,
      );

      expect(transaction.userId, 'user123');
      expect(transaction.nome, 'Salário');
      expect(transaction.valor, 5000.0);
      expect(transaction.amountCents, 500000);
      expect(transaction.type, 'entrada');
      expect(transaction.isGanho, true);
      expect(transaction.dateStr, '15/01/2024');
    });

    test('toMap should convert model to Map correctly', () {
      final now = DateTime(2024, 1, 15);
      final transaction = TransactionModel.fromReais(
        userId: 'user123',
        nome: 'Mercado',
        valor: 250.50,
        dataTime: now,
        isGanho: false,
      );

      final map = transaction.toMap();

      expect(map['userId'], 'user123');
      expect(map['nome'], 'Mercado');
      expect(map['amountCents'], 25050);
      expect(map['type'], 'saida');
      expect(map['dateStr'], '15/01/2024');
      expect(map['date'], isA<Timestamp>());
    });

    test('copyWith should create a copy with updated fields', () {
      final transaction = TransactionModel.fromReais(
        id: '1',
        userId: 'user123',
        nome: 'Original',
        valor: 100.0,
        dataTime: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final updated = transaction.copyWith(
        nome: 'Updated',
        amountCents: 20000,
      );

      expect(updated.id, '1');
      expect(updated.userId, 'user123');
      expect(updated.nome, 'Updated');
      expect(updated.amountCents, 20000);
      expect(updated.valor, 200.0);
      expect(updated.type, 'entrada');
    });

    test('valor getter should return correct amount in reais', () {
      final transaction = TransactionModel(
        userId: 'user123',
        nome: 'Test',
        amountCents: 12345,
        date: Timestamp.now(),
        dateStr: '15/01/2024',
        type: 'entrada',
      );

      expect(transaction.valor, 123.45);
    });

    test('isGanho getter should work correctly', () {
      final entrada = TransactionModel.fromReais(
        userId: 'user123',
        nome: 'Salário',
        valor: 5000.0,
        dataTime: DateTime.now(),
        isGanho: true,
      );

      final saida = TransactionModel.fromReais(
        userId: 'user123',
        nome: 'Mercado',
        valor: 250.0,
        dataTime: DateTime.now(),
        isGanho: false,
      );

      expect(entrada.isGanho, true);
      expect(entrada.type, 'entrada');
      expect(saida.isGanho, false);
      expect(saida.type, 'saida');
    });

    test('data getter should return DateTime from Timestamp', () {
      final testDate = DateTime(2024, 1, 15, 10, 30);
      final transaction = TransactionModel.fromReais(
        userId: 'user123',
        nome: 'Test',
        valor: 100.0,
        dataTime: testDate,
        isGanho: true,
      );

      final retrievedDate = transaction.data;
      expect(retrievedDate.year, testDate.year);
      expect(retrievedDate.month, testDate.month);
      expect(retrievedDate.day, testDate.day);
    });

    test('equality should work correctly', () {
      final date = DateTime(2024, 1, 1);
      final transaction1 = TransactionModel.fromReais(
        id: '1',
        userId: 'user123',
        nome: 'Test',
        valor: 100.0,
        dataTime: date,
        isGanho: true,
      );

      final transaction2 = TransactionModel.fromReais(
        id: '1',
        userId: 'user123',
        nome: 'Test',
        valor: 100.0,
        dataTime: date,
        isGanho: true,
      );

      final transaction3 = TransactionModel.fromReais(
        id: '2',
        userId: 'user123',
        nome: 'Test',
        valor: 100.0,
        dataTime: date,
        isGanho: true,
      );

      expect(transaction1, equals(transaction2));
      expect(transaction1, isNot(equals(transaction3)));
    });

    test('hashCode should be consistent', () {
      final date = DateTime(2024, 1, 1);
      final transaction1 = TransactionModel.fromReais(
        id: '1',
        userId: 'user123',
        nome: 'Test',
        valor: 100.0,
        dataTime: date,
        isGanho: true,
      );

      final transaction2 = TransactionModel.fromReais(
        id: '1',
        userId: 'user123',
        nome: 'Test',
        valor: 100.0,
        dataTime: date,
        isGanho: true,
      );

      expect(transaction1.hashCode, equals(transaction2.hashCode));
    });
  });
}
