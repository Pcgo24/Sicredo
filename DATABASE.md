# Database Implementation

This document describes the database implementation for the Sicredo app.

## Overview

The Sicredo app uses **Firebase Firestore** for cloud data persistence. This allows financial transactions and balance information to persist across devices and be synchronized in real-time.

> **Previous Version**: This app previously used SQLite (sqflite) for local persistence. The migration to Firestore was completed to enable cloud sync, multi-device support, and real-time updates.

## Architecture

### 1. Firebase Firestore Structure

The app uses Firestore with the following collection structure:

```
users/ (collection)
  └── {userId}/ (document)
      ├── saldo_total: number
      ├── created_at: timestamp
      ├── updated_at: timestamp
      └── transactions/ (subcollection)
          └── {transactionId}/ (document)
              ├── nome: string
              ├── valor: number
              ├── data: timestamp
              └── isGanho: boolean
```

**Key Features:**
- Multi-user support with user-scoped data
- Real-time synchronization across devices
- Automatic server timestamps
- Scalable cloud infrastructure
- Offline persistence (built-in with Firestore)

### 2. Transaction Model (`lib/data/models/transaction_model.dart`)

The `TransactionModel` class represents a financial transaction with Firestore serialization support.

**Properties:**
- `id`: Unique Firestore document identifier (String)
- `nome`: Transaction name/description
- `valor`: Transaction value (amount)
- `data`: Transaction date (DateTime)
- `isGanho`: Boolean flag (true for income, false for expense)

**Methods:**
- `toMap()`: Converts model to Map for Firestore insertion
- `fromFirestore()`: Creates model from Firestore DocumentSnapshot
- `fromMap()`: Creates model from Map (with backward compatibility)
- `copyWith()`: Creates a copy with updated fields

**Key Changes from SQLite Version:**
- ID changed from `int?` to `String?` (Firestore document IDs)
- Date stored as Firestore `Timestamp` instead of milliseconds
- Boolean stored natively (instead of 0/1)
- Added `fromFirestore()` factory for DocumentSnapshot handling

### 3. Transaction Repository (`lib/data/repositories/transaction_repository.dart`)

The `TransactionRepository` class provides CRUD operations for transactions using Firestore.

**Constructor:**
```dart
TransactionRepository({
  FirebaseFirestore? firestore,  // Injectable for testing
  String userId = 'default_user', // User ID for data scoping
})
```

**Methods:**
- `insertTransaction()`: Add a new transaction → Returns document ID (String)
- `getAllTransactions()`: Get all transactions (ordered by date DESC)
- `getTransactionsByMonth()`: Filter transactions by month/year
- `updateTransaction()`: Update an existing transaction
- `deleteTransaction()`: Remove a transaction by ID
- `getSaldoTotal()`: Get the current balance
- `updateSaldoTotal()`: Update the balance
- `calculateSaldoTotal()`: Calculate balance from all transactions
- `deleteAllTransactions()`: Clear all transactions

**Key Changes from SQLite Version:**
- Returns document ID (String) instead of row ID (int)
- Methods return `Future<void>` instead of row counts
- Uses Firestore queries instead of SQL
- Injectable Firestore instance for testing
- User-scoped collections for multi-user support

## Usage Example

```dart
import 'package:sicredo/data/models/transaction_model.dart';
import 'package:sicredo/data/repositories/transaction_repository.dart';

// Create repository instance (uses default user for now)
final repository = TransactionRepository();

// Add a new income transaction
final transaction = TransactionModel(
  nome: 'Salário',
  valor: 5000.0,
  data: DateTime.now(),
  isGanho: true,
);
final docId = await repository.insertTransaction(transaction);

// Update balance
final newBalance = await repository.getSaldoTotal() + 5000.0;
await repository.updateSaldoTotal(newBalance);

// Get all transactions
final transactions = await repository.getAllTransactions();

// Get transactions for specific month
final januaryTransactions = await repository.getTransactionsByMonth(1, 2024);

// Delete a transaction
await repository.deleteTransaction(docId);
```

## Integration with UI

The `HomeScreen` has been updated to:
1. Load transactions from Firestore on initialization
2. Save new transactions to Firestore when added
3. Update balance in Firestore when transactions change
4. Delete from Firestore when transactions are dismissed

## Security

Firestore security rules ensure that:
- Users can only access their own data
- All operations require authentication (in production)
- Default deny-all policy for unmatched paths

See `firebase/firestore.rules` for the complete security rules.

## Testing

The database implementation includes comprehensive tests:

- `test/data/models/transaction_model_test.dart`: Tests for TransactionModel serialization with Firestore Timestamps
- `test/data/repositories/transaction_repository_test.dart`: Tests for repository CRUD operations using FakeFirebaseFirestore
- `integration_test/app_flow_test.dart`: Integration tests with Firestore mocks

Run tests with:
```bash
flutter test
```

Run integration tests with:
```bash
flutter test integration_test/
```

## Firebase Setup

For detailed Firebase setup instructions, see [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

Quick setup:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure

# Run the app
flutter run
```

## Migration from SQLite

If you're migrating from the SQLite version:

1. **Data Migration**: No automatic migration is provided. Users will start fresh with Firestore.
2. **Breaking Changes**:
   - Transaction IDs changed from `int` to `String`
   - Repository methods return `void` instead of row counts
   - Database helper removed entirely
3. **Benefits**:
   - Cloud synchronization across devices
   - Real-time updates
   - No local database management
   - Built-in offline support
   - Scalable infrastructure

## Environment Configuration

### Development vs Production

Use different Firebase projects for dev and prod:

```bash
# Development
flutterfire configure --project=sicredo-dev

# Production
flutterfire configure --project=sicredo-prod
```

Or use Dart defines:
```bash
flutter run --dart-define=ENV=dev
flutter build apk --dart-define=ENV=prod
```

## Firestore Emulator (Local Testing)

For local development without using production Firestore:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Start emulator
firebase emulators:start
```

In code:
```dart
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

## Future Improvements

Potential enhancements for the database implementation:

1. **Add user authentication**: Integrate firebase_auth for real user IDs
2. **Add categories**: Create a categories collection to categorize transactions
3. **Add backup/restore**: Cloud backup already provided by Firestore
4. **Add budgets**: Budget tracking per category
5. **Add recurring transactions**: Support for scheduled recurring transactions
6. **Add data sharing**: Share financial data with family members
7. **Add analytics**: Track spending patterns with Firebase Analytics
8. **Add offline queue**: Better handling of offline operations
9. **Add pagination**: Load transactions in batches for better performance
10. **Add search**: Full-text search across transactions

## Dependencies

- `firebase_core: ^3.6.0` - Firebase Core SDK
- `cloud_firestore: ^5.4.4` - Cloud Firestore for Flutter
- `fake_cloud_firestore: ^3.0.3` (dev) - Fake Firestore for testing
- `firebase_auth_mocks: ^0.14.1` (dev) - Mock Firebase Auth for testing

## Removed Dependencies

The following dependencies were removed during the Firestore migration:
- ~~`sqflite: ^2.3.3`~~ - SQLite plugin (replaced by Firestore)
- ~~`path_provider: ^2.1.2`~~ - Filesystem access (no longer needed)
- ~~`path: ^1.9.0`~~ - Path manipulation (no longer needed)
- ~~`sqflite_common_ffi: ^2.3.2`~~ (dev) - SQLite FFI for testing (replaced by fake_cloud_firestore)

