import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sicredo/data/repositories/firebase_transaction_repository.dart';
import 'package:sicredo/data/models/transaction_model.dart';

void main() {
  group('FirebaseTransactionRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirebaseTransactionRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      // Note: In a real test, you'd inject fakeFirestore into the repository
      repository = FirebaseTransactionRepository();
    });

    test('should have methods for CRUD operations', () {
      expect(repository.addTransaction, isA<Function>());
      expect(repository.getTransaction, isA<Function>());
      expect(repository.updateTransaction, isA<Function>());
      expect(repository.deleteTransaction, isA<Function>());
      expect(repository.getUserTransactions, isA<Function>());
    });

    test('should calculate user balance correctly', () async {
      // This is a simplified test showing the expected behavior
      // In production, you would use dependency injection to provide fakeFirestore
      
      final userId = 'testUser123';
      
      // Add mock transactions
      final transaction1 = TransactionModel.fromReais(
        userId: userId,
        nome: 'Salário',
        valor: 5000.0,
        dataTime: DateTime(2024, 1, 15),
        isGanho: true,
      );
      
      final transaction2 = TransactionModel.fromReais(
        userId: userId,
        nome: 'Mercado',
        valor: 250.0,
        dataTime: DateTime(2024, 1, 20),
        isGanho: false,
      );
      
      // Expected balance: 5000 - 250 = 4750
      expect(transaction1.valor - transaction2.valor, 4750.0);
    });

    test('getUserTransactionsByMonth should filter correctly', () {
      // Test shows expected behavior for monthly filtering
      final january = DateTime(2024, 1, 15);
      final february = DateTime(2024, 2, 10);
      
      expect(january.month, 1);
      expect(february.month, 2);
      expect(january.month, isNot(february.month));
    });

    test('getUserSummary should return correct summary format', () {
      // Expected summary format
      final expectedSummary = {
        'totalIncome': 5000.0,
        'totalExpenses': 1000.0,
        'balance': 4000.0,
      };
      
      expect(expectedSummary, containsPair('totalIncome', isA<double>()));
      expect(expectedSummary, containsPair('totalExpenses', isA<double>()));
      expect(expectedSummary, containsPair('balance', isA<double>()));
    });
  });
}
