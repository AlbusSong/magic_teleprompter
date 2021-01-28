import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteTool {
  // 单例公开访问点
  factory SqliteTool() => _sharedInfo();

  // 静态私有成员，没有初始化
  static SqliteTool _instance = SqliteTool._();

  // 静态、同步、私有访问点
  static SqliteTool _sharedInfo() {
    return _instance;
  }

  // 私有构造函数
  SqliteTool._() {
    // 具体初始化代码
    _initSomeThings();
  }

  Database database;

  Future _initSomeThings() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'promters.db');
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE promters_table (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
      print("databasedddd: $db");
    });
  }

  Future<int> createPrompter(String title, String content) async {
    int id1 = await database.rawInsert(
        "INSERT INTO promters_table(title, content) VALUES(?, ?)",
        [title, content]);
    return id1;
  }

  Future<int> updatePrompter(int the_id, String title, String content) async {
    int res = await database.rawUpdate(
        "UPDATE promters_table SET title = ?, content = ?, update_time = datetime('now','localtime') WHERE id = ?",
        [title, content, the_id]);
    return res;
  }

  Future<List<Map>> getPromterList(int page, {int pageSize = 20}) async {
    List<Map> resultList = await database.rawQuery(
        "SELECT * FROM promters_table ORDER BY id DESC LIMIT ? OFFSET ?;",
        [pageSize, pageSize * page]);
    return resultList;
  }
}
