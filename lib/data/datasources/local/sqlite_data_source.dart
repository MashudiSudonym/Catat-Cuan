import 'package:catat_cuan/data/datasources/local/local_data_source.dart';
import 'package:catat_cuan/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite implementation of LocalDataSource
///
/// This class adapts the SQLite [DatabaseHelper] to the [LocalDataSource]
/// interface, following the Adapter pattern.
///
/// By implementing the [LocalDataSource] abstraction, this class:
/// 1. Follows DIP - depends on the abstraction (LocalDataSource)
/// 2. Follows OCP - can be extended without modifying repositories
/// 3. Follows LSP - can be substituted with any other LocalDataSource impl
class SqliteDataSource implements LocalDataSource {
  final DatabaseHelper _dbHelper;
  final Database? _directDb;

  SqliteDataSource(this._dbHelper) : _directDb = null;

  /// Creates a SqliteDataSource wrapping an existing [Database] instance.
  ///
  /// Useful for testing with in-memory databases from sqflite_common_ffi.
  SqliteDataSource.fromDatabase(Database db)
      : _dbHelper = DatabaseHelper(),
        _directDb = db;

  Future<Database> get _database async => _directDb ?? await _dbHelper.database;

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await _database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<Object?>? arguments,
  ) async {
    final db = await _database;
    return db.rawQuery(sql, arguments);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await _database;
    return db.insert(table, values);
  }

  @override
  Future<int> batchInsert(
      String table, List<Map<String, dynamic>> values) async {
    final db = await _database;
    final batch = db.batch();
    for (final value in values) {
      batch.insert(table, value);
    }
    final result = await batch.commit();
    return result.length;
  }

  @override
  Future<int> batchUpdate(
    String table,
    List<(Map<String, dynamic> values, String? where, List<Object>? whereArgs)>
        updates,
  ) async {
    final db = await _database;
    final batch = db.batch();
    for (final (values, where, whereArgs) in updates) {
      batch.update(table, values, where: where, whereArgs: whereArgs);
    }
    final result = await batch.commit();
    return result.length;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    final db = await _database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object>? whereArgs,
  }) async {
    final db = await _database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<void> transaction(
    Future<void> Function(LocalDataSource txn) action,
  ) async {
    final db = await _database;
    await db.transaction((sqfTxn) => action(_TxnDataSource(sqfTxn)));
  }

  @override
  Future<void> close() async {
    return _dbHelper.close();
  }
}

/// Txn-scoped [LocalDataSource] over a sqflite [DatabaseExecutor].
///
/// Created by [SqliteDataSource.transaction]: a sqflite [Transaction] IS-A
/// [DatabaseExecutor], so every method here delegates to the executor and
/// therefore runs inside the active transaction. This is the minimal-diff way
/// to let callers speak the [LocalDataSource] vocabulary while writing to the
/// txn — the caller's method calls are unchanged, only the target instance
/// changes.
class _TxnDataSource implements LocalDataSource {
  final DatabaseExecutor _executor;

  _TxnDataSource(this._executor);

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) =>
      _executor.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<Object?>? arguments,
  ) =>
      _executor.rawQuery(sql, arguments);

  @override
  Future<int> insert(String table, Map<String, dynamic> values) =>
      _executor.insert(table, values);

  @override
  Future<int> batchInsert(String table, List<Map<String, dynamic>> values) async {
    final batch = _executor.batch();
    for (final value in values) {
      batch.insert(table, value);
    }
    final result = await batch.commit();
    return result.length;
  }

  @override
  Future<int> batchUpdate(
    String table,
    List<(Map<String, dynamic> values, String? where, List<Object>? whereArgs)>
        updates,
  ) async {
    final batch = _executor.batch();
    for (final (values, where, whereArgs) in updates) {
      batch.update(table, values, where: where, whereArgs: whereArgs);
    }
    final result = await batch.commit();
    return result.length;
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object>? whereArgs,
  }) =>
      _executor.update(table, values, where: where, whereArgs: whereArgs);

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object>? whereArgs,
  }) =>
      _executor.delete(table, where: where, whereArgs: whereArgs);

  // ponytail: sqflite does not support nested transactions — restore is a
  // single top-level txn, so the adapter runs the callback inline on itself.
  @override
  Future<void> transaction(
    Future<void> Function(LocalDataSource txn) action,
  ) =>
      action(this);

  @override
  Future<void> close() async {
    // No-op: a transaction cannot close its parent database.
  }
}
