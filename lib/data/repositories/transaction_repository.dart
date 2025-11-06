import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

/// Repository for managing transaction data persistence with Firestore
/// Handles all CRUD operations for transactions and balance
class TransactionRepository {
  final FirebaseFirestore _firestore;
  final String _userId;

  // Collection references
  late final CollectionReference _transactionsCollection;
  late final DocumentReference _userSettingsDoc;

  TransactionRepository({
    FirebaseFirestore? firestore,
    String userId = 'default_user', // In production, use actual user ID from auth
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userId = userId {
    _transactionsCollection = _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions');
    _userSettingsDoc = _firestore.collection('users').doc(_userId);
  }

  /// Inserts a new transaction into Firestore
  /// Returns the id of the inserted transaction
  Future<String> insertTransaction(TransactionModel transaction) async {
    final docRef = await _transactionsCollection.add(transaction.toMap());
    return docRef.id;
  }

  /// Gets all transactions from Firestore
  /// Returns a list of transactions ordered by date (newest first)
  Future<List<TransactionModel>> getAllTransactions() async {
    final querySnapshot = await _transactionsCollection
        .orderBy('data', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  /// Gets transactions filtered by month and year
  Future<List<TransactionModel>> getTransactionsByMonth(
    int month,
    int year,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1)
        .subtract(const Duration(microseconds: 1));

    final querySnapshot = await _transactionsCollection
        .where('data',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('data', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  /// Updates an existing transaction
  /// Returns void (Firestore doesn't return affected rows count)
  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Transaction ID cannot be null for update');
    }
    await _transactionsCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  /// Deletes a transaction by id
  /// Returns void (Firestore doesn't return affected rows count)
  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }

  /// Gets the current total balance from user settings
  Future<double> getSaldoTotal() async {
    final doc = await _userSettingsDoc.get();
    if (!doc.exists) {
      // Initialize with default value if doesn't exist
      await _userSettingsDoc.set({
        'saldo_total': 0.0,
        'created_at': FieldValue.serverTimestamp(),
      });
      return 0.0;
    }
    final data = doc.data() as Map<String, dynamic>?;
    return (data?['saldo_total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Updates the total balance in user settings
  Future<void> updateSaldoTotal(double saldoTotal) async {
    await _userSettingsDoc.set({
      'saldo_total': saldoTotal,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Calculates the total balance based on all transactions
  /// This can be used to verify or recalculate the balance
  Future<double> calculateSaldoTotal() async {
    final transactions = await getAllTransactions();
    double total = 0.0;

    for (var transaction in transactions) {
      if (transaction.isGanho) {
        total += transaction.valor;
      } else {
        total -= transaction.valor;
      }
    }

    return total;
  }

  /// Deletes all transactions (useful for testing or reset)
  Future<void> deleteAllTransactions() async {
    final querySnapshot = await _transactionsCollection.get();
    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    await updateSaldoTotal(0.0);
  }
}
