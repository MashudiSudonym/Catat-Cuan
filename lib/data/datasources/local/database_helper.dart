import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:catat_cuan/data/datasources/local/schema_manager.dart';

/// Database helper for managing SQLite connections
///
/// This class is responsible for:
/// - Database connection management
/// - Providing access to the database instance
///
/// Schema operations (table creation, migrations) are handled by
/// [DatabaseSchemaManager] following the Single Responsibility Principle.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Database file name
  static const String _databaseName = 'catat_cuan.db';

  /// Table names
  static const String tableTransactions = 'transactions';
  static const String tableCategories = 'categories';

  /// Gets the database instance, initializing it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database connection
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: DatabaseSchemaManager.currentVersion,
      onCreate: DatabaseSchemaManager.onCreate,
      onUpgrade: DatabaseSchemaManager.onUpgrade,
    );
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clears all data from all tables
  ///
  /// WARNING: This is a destructive operation intended only for
  /// development and testing purposes.
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(tableTransactions);
    await db.delete(tableCategories);
  }
}
