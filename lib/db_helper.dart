import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('counter.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE counters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        count INTEGER NOT NULL
      )
    ''');
  }

  Future<int> createCounter(String name, int count) async {
    final db = await instance.database;

    final data = {'name': name, 'count': count};
    return await db.insert('counters', data);
  }

  Future<List<Map<String, dynamic>>> readAllCounters() async {
    final db = await instance.database;

    return await db.query('counters');
  }

  Future<int> updateCounter(int id, String name, int count) async {
    final db = await instance.database;

    final data = {'name': name, 'count': count};
    return await db.update('counters', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCounter(int id) async {
    final db = await instance.database;

    return await db.delete('counters', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
