# Migration Guide: SQLite to Firebase Firestore

This guide helps developers understand the changes made during the migration from SQLite to Firebase Firestore.

## Overview

The Sicredo app has been migrated from local SQLite storage to cloud-based Firebase Firestore. This migration enables:

- ✅ Cloud synchronization across devices
- ✅ Real-time data updates
- ✅ Multi-user support
- ✅ Built-in offline support
- ✅ Scalable infrastructure
- ✅ No local database management

## Breaking Changes

### 1. Transaction ID Type Change

**Before (SQLite):**
```dart
class TransactionModel {
  final int? id;  // Auto-incremented integer
  // ...
}
```

**After (Firestore):**
```dart
class TransactionModel {
  final String? id;  // Firestore document ID
  // ...
}
```

**Impact:**
- Any code referencing transaction IDs must be updated
- HomeScreen's `EntradaExtrato` class updated to use `String? id`

### 2. Repository Method Return Types

**Before (SQLite):**
```dart
Future<int> insertTransaction(TransactionModel transaction);  // Returns row ID
Future<int> updateTransaction(TransactionModel transaction);  // Returns affected rows
Future<int> deleteTransaction(int id);  // Returns affected rows
```

**After (Firestore):**
```dart
Future<String> insertTransaction(TransactionModel transaction);  // Returns document ID
Future<void> updateTransaction(TransactionModel transaction);   // No return value
Future<void> deleteTransaction(String id);  // No return value
```

**Impact:**
- Code checking return values from update/delete must be updated
- Success is indicated by no exception being thrown

### 3. Database Helper Removed

**Before:**
- `lib/data/database/database_helper.dart` managed SQLite connection
- Singleton pattern for database instance

**After:**
- No database helper needed
- Firebase automatically handles connection management
- Repository directly uses `FirebaseFirestore.instance`

### 4. Date Storage Format

**Before (SQLite):**
- Dates stored as milliseconds since epoch (int)
```dart
'data': data.millisecondsSinceEpoch
```

**After (Firestore):**
- Dates stored as Firestore Timestamp
```dart
'data': Timestamp.fromDate(data)
```

### 5. Boolean Storage

**Before (SQLite):**
- Booleans stored as integers (0/1)
```dart
'isGanho': isGanho ? 1 : 0
```

**After (Firestore):**
- Booleans stored natively
```dart
'isGanho': isGanho
```

### 6. User Scoping

**Before (SQLite):**
- Single user, all data in one database
- User settings stored in `user_settings` table

**After (Firestore):**
- Multi-user support with user-scoped collections
- Structure: `users/{userId}/transactions/{transactionId}`
- User settings stored in user document

### 7. Dependency Changes

**Removed:**
```yaml
dependencies:
  sqflite: ^2.3.3
  path: ^1.9.0
  path_provider: ^2.1.2

dev_dependencies:
  sqflite_common_ffi: ^2.3.2
```

**Added:**
```yaml
dependencies:
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.4

dev_dependencies:
  fake_cloud_firestore: ^3.0.3
  firebase_auth_mocks: ^0.14.1
```

## Code Migration Examples

### Example 1: Creating a Transaction

**Before (SQLite):**
```dart
final repository = TransactionRepository();
final transaction = TransactionModel(
  nome: 'Salário',
  valor: 5000.0,
  data: DateTime.now(),
  isGanho: true,
);

final id = await repository.insertTransaction(transaction);
print('Inserted with ID: $id');  // ID is int
```

**After (Firestore):**
```dart
final repository = TransactionRepository();  // Default user
// Or with specific user:
// final repository = TransactionRepository(userId: userId);

final transaction = TransactionModel(
  nome: 'Salário',
  valor: 5000.0,
  data: DateTime.now(),
  isGanho: true,
);

final docId = await repository.insertTransaction(transaction);
print('Inserted with ID: $docId');  // ID is String
```

### Example 2: Deleting a Transaction

**Before (SQLite):**
```dart
final affectedRows = await repository.deleteTransaction(transactionId);
if (affectedRows > 0) {
  print('Transaction deleted');
}
```

**After (Firestore):**
```dart
try {
  await repository.deleteTransaction(transactionId);
  print('Transaction deleted');
} catch (e) {
  print('Error deleting: $e');
}
```

### Example 3: Testing

**Before (SQLite):**
```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sicredo/data/database/database_helper.dart';

setUpAll(() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
});

setUp(() async {
  await DatabaseHelper.instance.reset();
});

test('insert transaction', () async {
  final repository = TransactionRepository();
  // ...
});
```

**After (Firestore):**
```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

late FakeFirebaseFirestore fakeFirestore;
late TransactionRepository repository;

setUp(() {
  fakeFirestore = FakeFirebaseFirestore();
  repository = TransactionRepository(
    firestore: fakeFirestore,
    userId: 'test_user',
  );
});

test('insert transaction', () async {
  // ...
});
```

## Data Migration

### No Automatic Migration

⚠️ **Important:** There is no automatic data migration from SQLite to Firestore.

When users update to this version:
- They will start with an empty balance and no transactions
- Previous SQLite data will remain on the device but won't be used
- Consider implementing a manual export/import feature if needed

### Manual Migration (If Needed)

If you need to migrate existing data:

```dart
// Pseudo-code for migration
Future<void> migrateData() async {
  // 1. Read from old SQLite database
  final oldDb = await openDatabase('sicredo.db');
  final oldTransactions = await oldDb.query('transactions');
  
  // 2. Write to Firestore
  final repository = TransactionRepository(userId: currentUserId);
  
  for (final row in oldTransactions) {
    final transaction = TransactionModel(
      nome: row['nome'] as String,
      valor: row['valor'] as double,
      data: DateTime.fromMillisecondsSinceEpoch(row['data'] as int),
      isGanho: row['isGanho'] == 1,
    );
    
    await repository.insertTransaction(transaction);
  }
  
  // 3. Migrate balance
  final oldBalance = await oldDb.query('user_settings');
  if (oldBalance.isNotEmpty) {
    final saldo = oldBalance.first['saldo_total'] as double;
    await repository.updateSaldoTotal(saldo);
  }
}
```

## Testing Strategy

### Unit Tests

All unit tests now use `fake_cloud_firestore` instead of `sqflite_common_ffi`:

```dart
// Create fake Firestore instance
final fakeFirestore = FakeFirebaseFirestore();

// Inject into repository
final repository = TransactionRepository(
  firestore: fakeFirestore,
  userId: 'test_user',
);

// Test normally
final id = await repository.insertTransaction(transaction);
expect(id, isNotEmpty);
```

### Integration Tests

Integration tests should mock Firebase initialization:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

setUp(() async {
  fakeFirestore = FakeFirebaseFirestore();
  // Clear data
  final repository = TransactionRepository(
    firestore: fakeFirestore,
    userId: 'test_user',
  );
  await repository.deleteAllTransactions();
});
```

### Local Testing with Emulator

For more realistic testing, use Firebase Emulator:

```bash
firebase emulators:start
```

```dart
// In your app
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

## Configuration Requirements

### Before Running the App

1. **Create Firebase Project:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project

2. **Enable Firestore:**
   - In your project, enable Firestore Database

3. **Configure FlutterFire:**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. **Deploy Security Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions.

## Common Issues and Solutions

### Issue: "Default FirebaseApp is not initialized"

**Solution:** Ensure Firebase is initialized before using Firestore:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: SicredoApp()));
}
```

### Issue: "PERMISSION_DENIED"

**Solution:** Check Firestore security rules. In development, you can temporarily allow all access:
```javascript
match /{document=**} {
  allow read, write: if true;  // Only for development!
}
```

### Issue: Tests failing with Firebase initialization errors

**Solution:** Use `FakeFirebaseFirestore` in tests instead of real Firebase:
```dart
final fakeFirestore = FakeFirebaseFirestore();
final repository = TransactionRepository(
  firestore: fakeFirestore,
  userId: 'test_user',
);
```

### Issue: Build errors about missing google-services.json

**Solution:** Run `flutterfire configure` to generate platform-specific configuration files.

## Performance Considerations

### Query Optimization

Firestore charges per read/write. Optimize queries:

```dart
// Good: Query with limit
final recentTransactions = await _transactionsCollection
    .orderBy('data', descending: true)
    .limit(10)
    .get();

// Bad: Query all then filter in memory
final allTransactions = await _transactionsCollection.get();
final recent = allTransactions.docs.take(10);
```

### Offline Persistence

Firestore has built-in offline persistence (enabled by default):
- Reads from cache when offline
- Writes queued and synced when online
- No code changes needed

### Batch Operations

For multiple operations, use batch writes:

```dart
final batch = _firestore.batch();
for (final transaction in transactions) {
  final docRef = _transactionsCollection.doc();
  batch.set(docRef, transaction.toMap());
}
await batch.commit();
```

## Next Steps

1. **Add Authentication:**
   - Integrate `firebase_auth`
   - Update security rules to use `request.auth.uid`
   - Pass real user IDs to repository

2. **Add Real-time Listeners:**
   - Use `.snapshots()` instead of `.get()`
   - Update UI automatically when data changes

3. **Add Pagination:**
   - Use `startAfter()` for infinite scroll
   - Load data in chunks

4. **Add Search:**
   - Consider Algolia or ElasticSearch for full-text search
   - Or use Firestore array-contains for simple filtering

## Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Migration Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)

## Support

For issues related to this migration:
1. Check [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for setup instructions
2. Review [DATABASE.md](DATABASE.md) for architecture details
3. Open an issue on GitHub with migration-specific questions
