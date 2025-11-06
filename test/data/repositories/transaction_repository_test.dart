import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/data/models/transaction_model.dart';
import 'package:sicredo/data/repositories/transaction_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('TransactionRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TransactionRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = TransactionRepository(
        firestore: fakeFirestore,
        userId: 'test_user',
      );
    });

    test('insertTransaction should add transaction to Firestore', () async {
      final transaction = TransactionModel(
        nome: 'Salário',
        valor: 5000.0,
        data: DateTime(2024, 1, 15),
        isGanho: true,
      );

      final id = await repository.insertTransaction(transaction);

      expect(id, isNotEmpty);

      final transactions = await repository.getAllTransactions();
      expect(transactions.length, 1);
      expect(transactions.first.nome, 'Salário');
      expect(transactions.first.valor, 5000.0);
      expect(transactions.first.isGanho, true);
    });

    test('getAllTransactions should return all transactions ordered by date', () async {
      await repository.insertTransaction(TransactionModel(
        nome: 'First',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'Second',
        valor: 50.0,
        data: DateTime(2024, 1, 2),
        isGanho: false,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'Third',
        valor: 75.0,
        data: DateTime(2024, 1, 3),
        isGanho: true,
      ));

      final transactions = await repository.getAllTransactions();

      expect(transactions.length, 3);
      // Should be ordered by date DESC (newest first)
      expect(transactions[0].nome, 'Third');
      expect(transactions[1].nome, 'Second');
      expect(transactions[2].nome, 'First');
    });

    test('getTransactionsByMonth should filter transactions correctly', () async {
      await repository.insertTransaction(TransactionModel(
        nome: 'January',
        valor: 100.0,
        data: DateTime(2024, 1, 10),
        isGanho: true,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'February',
        valor: 50.0,
        data: DateTime(2024, 2, 10),
        isGanho: false,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'January 2',
        valor: 75.0,
        data: DateTime(2024, 1, 20),
        isGanho: true,
      ));

      final januaryTransactions = await repository.getTransactionsByMonth(1, 2024);

      expect(januaryTransactions.length, 2);
      expect(januaryTransactions.any((t) => t.nome == 'January'), true);
      expect(januaryTransactions.any((t) => t.nome == 'January 2'), true);
      expect(januaryTransactions.any((t) => t.nome == 'February'), false);
    });

    test('getTransactionsByMonth should handle December correctly', () async {
      await repository.insertTransaction(TransactionModel(
        nome: 'December Early',
        valor: 100.0,
        data: DateTime(2024, 12, 1),
        isGanho: true,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'December End',
        valor: 50.0,
        data: DateTime(2024, 12, 31, 23, 59, 59),
        isGanho: false,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'January Next Year',
        valor: 75.0,
        data: DateTime(2025, 1, 1),
        isGanho: true,
      ));

      final decemberTransactions = await repository.getTransactionsByMonth(12, 2024);

      expect(decemberTransactions.length, 2);
      expect(decemberTransactions.any((t) => t.nome == 'December Early'), true);
      expect(decemberTransactions.any((t) => t.nome == 'December End'), true);
      expect(decemberTransactions.any((t) => t.nome == 'January Next Year'), false);
    });

    test('updateTransaction should modify existing transaction', () async {
      final transaction = TransactionModel(
        nome: 'Original',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final id = await repository.insertTransaction(transaction);
      final updatedTransaction = transaction.copyWith(
        id: id,
        nome: 'Updated',
        valor: 200.0,
      );

      await repository.updateTransaction(updatedTransaction);

      final transactions = await repository.getAllTransactions();
      expect(transactions.length, 1);
      expect(transactions.first.nome, 'Updated');
      expect(transactions.first.valor, 200.0);
    });

    test('deleteTransaction should remove transaction from Firestore', () async {
      final transaction = TransactionModel(
        nome: 'To Delete',
        valor: 100.0,
        data: DateTime(2024, 1, 1),
        isGanho: true,
      );

      final id = await repository.insertTransaction(transaction);
      expect(id, isNotEmpty);

      var transactions = await repository.getAllTransactions();
      expect(transactions.length, 1);

      await repository.deleteTransaction(id);

      transactions = await repository.getAllTransactions();
      expect(transactions.length, 0);
    });

    test('getSaldoTotal should return current balance', () async {
      final saldo = await repository.getSaldoTotal();
      expect(saldo, 0.0);
    });

    test('updateSaldoTotal should update the balance', () async {
      await repository.updateSaldoTotal(1500.50);
      
      final saldo = await repository.getSaldoTotal();
      expect(saldo, 1500.50);
    });

    test('calculateSaldoTotal should calculate balance from transactions', () async {
      await repository.insertTransaction(TransactionModel(
        nome: 'Income',
        valor: 1000.0,
        data: DateTime.now(),
        isGanho: true,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'Expense',
        valor: 300.0,
        data: DateTime.now(),
        isGanho: false,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'Income 2',
        valor: 500.0,
        data: DateTime.now(),
        isGanho: true,
      ));

      final calculatedBalance = await repository.calculateSaldoTotal();
      expect(calculatedBalance, 1200.0); // 1000 - 300 + 500
    });

    test('deleteAllTransactions should remove all transactions and reset balance', () async {
      await repository.insertTransaction(TransactionModel(
        nome: 'Transaction 1',
        valor: 100.0,
        data: DateTime.now(),
        isGanho: true,
      ));

      await repository.insertTransaction(TransactionModel(
        nome: 'Transaction 2',
        valor: 50.0,
        data: DateTime.now(),
        isGanho: false,
      ));

      await repository.updateSaldoTotal(50.0);

      var transactions = await repository.getAllTransactions();
      expect(transactions.length, 2);

      await repository.deleteAllTransactions();

      transactions = await repository.getAllTransactions();
      expect(transactions.length, 0);

      final saldo = await repository.getSaldoTotal();
      expect(saldo, 0.0);
    });
  });
}
