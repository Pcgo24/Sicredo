import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

/// Repository for managing transaction data in Firestore
/// Handles all CRUD operations for transactions
class FirebaseTransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get transactions collection reference
  CollectionReference get _transactionsCollection =>
      _firestore.collection('transactions');

  /// Add a new transaction
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _transactionsCollection.add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransaction(String id) async {
    try {
      final doc = await _transactionsCollection.doc(id).get();
      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    try {
      await _transactionsCollection.doc(id).update(transaction.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Get all transactions for a user
  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get transactions for a user in a date range
  Future<List<TransactionModel>> getUserTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startTimestamp = Timestamp.fromDate(startDate);
      final endTimestamp = Timestamp.fromDate(endDate);

      final querySnapshot = await _transactionsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .where('date', isLessThanOrEqualTo: endTimestamp)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get transactions for a user by month and year
  Future<List<TransactionModel>> getUserTransactionsByMonth({
    required String userId,
    required int month,
    required int year,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return getUserTransactionsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Stream of user transactions (real-time updates)
  Stream<List<TransactionModel>> getUserTransactionsStream(String userId) {
    return _transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  /// Calculate total balance for a user
  Future<double> calculateUserBalance(String userId) async {
    try {
      final transactions = await getUserTransactions(userId);
      double balance = 0.0;

      for (var transaction in transactions) {
        if (transaction.type == 'entrada') {
          balance += transaction.valor;
        } else {
          balance -= transaction.valor;
        }
      }

      return balance;
    } catch (e) {
      rethrow;
    }
  }

  /// Get summary for a user (total income, total expenses, balance)
  Future<Map<String, double>> getUserSummary(String userId) async {
    try {
      final transactions = await getUserTransactions(userId);
      double totalIncome = 0.0;
      double totalExpenses = 0.0;

      for (var transaction in transactions) {
        if (transaction.type == 'entrada') {
          totalIncome += transaction.valor;
        } else {
          totalExpenses += transaction.valor;
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get summary for a user by month
  Future<Map<String, double>> getUserMonthlySummary({
    required String userId,
    required int month,
    required int year,
  }) async {
    try {
      final transactions = await getUserTransactionsByMonth(
        userId: userId,
        month: month,
        year: year,
      );

      double totalIncome = 0.0;
      double totalExpenses = 0.0;

      for (var transaction in transactions) {
        if (transaction.type == 'entrada') {
          totalIncome += transaction.valor;
        } else {
          totalExpenses += transaction.valor;
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all transactions for a user (useful for testing)
  Future<void> deleteAllUserTransactions(String userId) async {
    try {
      final querySnapshot = await _transactionsCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
