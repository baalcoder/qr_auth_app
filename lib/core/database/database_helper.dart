import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "qr_scanner.db";
  static const _databaseVersion = 1;

  static const table = 'qr_codes';

  static const columnId = 'id';
  static const columnData = 'data';
  static const columnTimestamp = 'timestamp';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnData TEXT NOT NULL,
        $columnTimestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertQRCode(String data) async {
    Database db = await database;
    Map<String, dynamic> row = {
      columnData: data,
      columnTimestamp: DateTime.now().toIso8601String(),
    };
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> getQRCodes() async {
    Database db = await database;
    return await db.query(
      table,
      orderBy: '$columnTimestamp DESC',
    );
  }

  Future<void> deleteQRCode(int id) async {
    Database db = await database;
    await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearQRCodes() async {
    Database db = await database;
    await db.delete(table);
  }
}