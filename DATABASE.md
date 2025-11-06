# Database Implementation

This document describes the database implementation for the Sicredo app.

## Overview

The Sicredo app uses SQLite for local data persistence through the `sqflite` package. This allows financial transactions and balance information to persist across app restarts.

## Architecture

### 1. Database Helper (`lib/data/database/database_helper.dart`)

The `DatabaseHelper` class manages the SQLite database connection using the singleton pattern to ensure only one database instance exists throughout the app lifecycle.

**Key Features:**
- Singleton pattern for database instance management
- Automatic table creation on first run
- Database version management
- Reset functionality for testing

**Tables:**
- `transactions`: Stores all financial transactions (income and expenses)
- `user_settings`: Stores user preferences and total balance

### 2. Transaction Model (`lib/data/models/transaction_model.dart`)

The `TransactionModel` class represents a financial transaction with serialization support.

**Properties:**
- `id`: Unique identifier (auto-incremented)
- `nome`: Transaction name/description
- `valor`: Transaction value (amount)
- `data`: Transaction date
- `isGanho`: Boolean flag (true for income, false for expense)

**Methods:**
- `toMap()`: Converts model to Map for database insertion
- `fromMap()`: Creates model from database Map
- `copyWith()`: Creates a copy with updated fields

### 3. Transaction Repository (`lib/data/repositories/transaction_repository.dart`)

The `TransactionRepository` class provides CRUD operations for transactions.

**Methods:**
- `insertTransaction()`: Add a new transaction
- `getAllTransactions()`: Get all transactions (ordered by date)
- `getTransactionsByMonth()`: Filter transactions by month/year
- `updateTransaction()`: Update an existing transaction
- `deleteTransaction()`: Remove a transaction by ID
- `getSaldoTotal()`: Get the current balance
- `updateSaldoTotal()`: Update the balance
- `calculateSaldoTotal()`: Calculate balance from all transactions
- `deleteAllTransactions()`: Clear all transactions

## Usage Example

```dart
import 'package:sicredo/data/models/transaction_model.dart';
import 'package:sicredo/data/repositories/transaction_repository.dart';

// Create repository instance
final repository = TransactionRepository();

// Add a new income transaction
final transaction = TransactionModel(
  nome: 'Salário',
  valor: 5000.0,
  data: DateTime.now(),
  isGanho: true,
);
final id = await repository.insertTransaction(transaction);

// Update balance
final newBalance = await repository.getSaldoTotal() + 5000.0;
await repository.updateSaldoTotal(newBalance);

// Get all transactions
final transactions = await repository.getAllTransactions();

// Get transactions for specific month
final januaryTransactions = await repository.getTransactionsByMonth(1, 2024);

// Delete a transaction
await repository.deleteTransaction(id);
```

## Integration with UI

The `HomeScreen` has been updated to:
1. Load transactions from database on initialization
2. Save new transactions to database when added
3. Update balance in database when transactions change
4. Delete from database when transactions are dismissed

## Testing

The database implementation includes comprehensive unit tests:

- `test/data/models/transaction_model_test.dart`: Tests for TransactionModel serialization
- `test/data/repositories/transaction_repository_test.dart`: Tests for repository CRUD operations
- `integration_test/app_flow_test.dart`: Integration tests with database reset between tests

Run tests with:
```bash
flutter test
```

Run integration tests with:
```bash
flutter test integration_test/
```

## Database Schema

### transactions table
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  valor REAL NOT NULL,
  data INTEGER NOT NULL,
  isGanho INTEGER NOT NULL
)
```

### user_settings table
```sql
CREATE TABLE user_settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  saldo_total REAL NOT NULL DEFAULT 0.0
)
```

## Future Improvements

Potential enhancements for the database implementation:

1. **Add categories**: Create a categories table to categorize transactions
2. **Add user authentication**: Support multiple user profiles with separate data
3. **Add backup/restore**: Export and import database data
4. **Add sync**: Cloud synchronization for data backup
5. **Add budgets**: Budget tracking per category
6. **Add recurring transactions**: Support for scheduled recurring transactions
7. **Performance optimization**: Add indexes for frequently queried columns
8. **Data migration**: Version management for schema changes

## Dependencies

- `sqflite: ^2.3.0` - SQLite plugin for Flutter
- `path_provider: ^2.1.1` - Access to commonly used locations on the filesystem
- `path: ^1.8.3` - Path manipulation library
- `sqflite_common_ffi: ^2.3.0` (dev) - FFI implementation for testing
