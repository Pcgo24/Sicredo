import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper class to manage SQLite database operations
/// Implements singleton pattern to ensure single database instance
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  /// Gets the database instance, creating it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates tables
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sicredo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Creates database tables on first run
  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        valor REAL NOT NULL,
        data INTEGER NOT NULL,
        isGanho INTEGER NOT NULL
      )
    ''');

    // Create user_settings table for storing user preferences and balance
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        saldo_total REAL NOT NULL DEFAULT 0.0
      )
    ''');

    // Insert default settings
    await db.insert('user_settings', {'id': 1, 'saldo_total': 0.0});
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Resets the database (useful for testing)
  Future<void> reset() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sicredo.db');
    await deleteDatabase(path);
    _database = null;
  }
}
