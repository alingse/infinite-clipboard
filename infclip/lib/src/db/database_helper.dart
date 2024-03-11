
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static const String dbName = "sample_db.db";


  static Future<Database> getDatabase() async {

    var databasesPath = await getDatabasesPath();
    var path = '$databasesPath/$dbName';
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }


  static Future<void> _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE items (id INTEGER PRIMARY KEY, data TEXT)");
  }


  static Future<Map<String, dynamic>>? getItemById(int id) async {
    final db = await getDatabase();
    final results = await db.query("items", where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return <String, dynamic>{
      "data": "hello",
    };
  }
}
