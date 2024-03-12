import 'package:sqflite/sqflite.dart';
import '../model/record.dart';

class DatabaseProvider {
  static const String _databaseName = 'my_database.db';
  static const String _tableName = 'records';
  static Database? _database;

  DatabaseProvider._(); // 私有构造函数，防止类被实例化

  static Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  static Future<Database> _open() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/$_databaseName';

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT,
            created_at TEXT,
            copy_times INTEGER
          )
        ''');
      },
    );
  }

  static Future<void> insertRecord(String content) async {
    final record = Record(
      id: 0,
      content: content,
      createdAt: DateTime.now(),
      copyTimes: 0,
    );
    final db = await database;
    await db.insert(_tableName, record.toInsertMap());
  }

  static Future<List<Record>> getRecords(int page, int pageSize) async {
    final db = await database;
    final offset = (page - 1) * pageSize;
    const orderBy = 'created_at DESC';
    final rows = await db.query(
      _tableName,
      orderBy: orderBy,
      limit: pageSize,
      offset: offset,
    );

    return rows.map((row) => Record.fromMap(row)).toList();
  }

  static Future<Record?> getRecordByID(int id) async {
    final db = await database;
    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null; // 如果没有找到记录，则返回 null
    }

    return Record.fromMap(rows.first);
  }
}
