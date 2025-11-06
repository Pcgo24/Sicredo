import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

/// Repository for managing transaction data persistence
/// Handles all CRUD operations for transactions and balance
class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Inserts a new transaction into the database
  /// Returns the id of the inserted transaction
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  /// Gets all transactions from the database
  /// Returns a list of transactions ordered by date (newest first)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'data DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  /// Gets transactions filtered by month and year
  Future<List<TransactionModel>> getTransactionsByMonth(
    int month,
    int year,
  ) async {
    final db = await _dbHelper.database;
    
    // Calculate start and end timestamps for the month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'data >= ? AND data <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'data DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  /// Updates an existing transaction
  /// Returns the number of rows affected
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// Deletes a transaction by id
  /// Returns the number of rows affected
  Future<int> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets the current total balance from user settings
  Future<double> getSaldoTotal() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'user_settings',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (result.isNotEmpty) {
      return result.first['saldo_total'] as double;
    }
    return 0.0;
  }

  /// Updates the total balance in user settings
  Future<int> updateSaldoTotal(double saldoTotal) async {
    final db = await _dbHelper.database;
    return await db.update(
      'user_settings',
      {'saldo_total': saldoTotal},
      where: 'id = ?',
      whereArgs: [1],
    );
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
    final db = await _dbHelper.database;
    await db.delete('transactions');
    await updateSaldoTotal(0.0);
  }
}
