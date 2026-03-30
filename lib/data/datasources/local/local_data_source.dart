/// Abstract data source for local storage
///
/// This interface follows the Open/Closed Principle (OCP) by allowing
/// the data source implementation to be extended without modifying
/// the repository implementations that depend on it.
///
/// It also follows the Dependency Inversion Principle (DIP) by providing
/// an abstraction that high-level modules (repositories) depend on,
/// rather than depending on concrete implementations like DatabaseHelper.
///
/// Implementations:
/// - [SqliteDataSource] for SQLite databases
/// - Future: HiveDataSource for Hive NoSQL database
/// - Future: IsarDataSource for Isar database
/// - Future: RestApiDataSource for remote REST APIs
abstract class LocalDataSource {
  /// Query the data source with the given parameters
  ///
  /// Similar to SQLite's query method but abstracted to work with
  /// any local storage implementation.
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
  });

  /// Execute a raw query on the data source
  ///
  /// Allows for complex queries that cannot be expressed with [query].
  /// The SQL syntax should be compatible with the underlying implementation.
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<Object?>? arguments,
  );

  /// Insert data into the specified table
  ///
  /// Returns the ID of the inserted row.
  Future<int> insert(String table, Map<String, dynamic> values);

  /// Insert multiple rows into the specified table in a single transaction
  ///
  /// Uses SQLite batch operation for efficient bulk inserts.
  /// All inserts succeed or fail together.
  ///
  /// Returns the number of rows inserted.
  Future<int> batchInsert(String table, List<Map<String, dynamic>> values);

  /// Update multiple rows in a single transaction
  ///
  /// Uses SQLite batch operation for efficient bulk updates.
  /// All updates succeed or fail together.
  ///
  /// [updates] is a list of tuples containing (values, where, whereArgs).
  /// Returns the number of rows updated.
  Future<int> batchUpdate(
    String table,
    List<(Map<String, dynamic> values, String? where, List<Object>? whereArgs)>
        updates,
  );

  /// Update data in the specified table
  ///
  /// Returns the number of rows affected.
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object>? whereArgs,
  });

  /// Delete data from the specified table
  ///
  /// Returns the number of rows deleted.
  Future<int> delete(
    String table, {
    String? where,
    List<Object>? whereArgs,
  });

  /// Execute multiple operations in a single transaction
  ///
  /// All operations within [action] will be executed atomically.
  /// If any operation fails, all changes will be rolled back.
  Future<void> transaction(Future<void> Function() action);

  /// Close the data source and release resources
  Future<void> close();
}
