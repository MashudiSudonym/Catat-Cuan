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

  SqliteDataSource(this._dbHelper);

  Future<Database> get _database async => await _dbHelper.database;

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
  Future<void> transaction(Future<void> Function() action) async {
    final db = await _database;
    return db.transaction((_) async => await action());
  }

  @override
  Future<void> close() async {
    return _dbHelper.close();
  }
}
