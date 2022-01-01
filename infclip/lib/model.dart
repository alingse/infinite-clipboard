import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String contentTypeEnumText = 'text';

class ContentItem {
  final int? id;
  final String content;
  final String contentType;

  ContentItem(
    this.id,
    this.content,
    this.contentType,
  );

  ContentItem.fromMap(Map<String, dynamic> row)
      : id = row["id"],
        content = row["content"],
        contentType = row["contentType"];

  Map<String, Object?> toMap() {
    return {
      'content': content,
      'contentType': contentType,
    };
  }
}

class DatabaseHandler {
  int duplLimit = 3;

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'infclip.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE contents(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT NOT NULL, contentType TEXT NOT NULL, createdAt DATETIME DEFAULT current_timestamp)",
        );
      },
      version: 1,
      singleInstance: false,
    );
  }

  Future<void> saveItem(ContentItem item) async {
    final Database db = await initializeDB();
    await db.transaction((txn) async {
      var rows =
          await txn.query('contents', orderBy: "id DESC", limit: duplLimit);
      for (var row in rows) {
        if (ContentItem.fromMap(row).content == item.content) {
          return;
        }
      }
      await txn.insert('contents', item.toMap());
    });
  }

  Future<List<ContentItem>> queryItems() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('contents');
    return queryResult.reversed.map((e) => ContentItem.fromMap(e)).toList();
  }
}
