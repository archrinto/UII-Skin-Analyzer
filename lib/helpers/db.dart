import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'skin_analyzer.db'), onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE analysis_results(id TEXT PRIMARY KEY NOT NULL, email TEXT NOT NULL, image_path TEXT NOT NULL, jerawat_result TEXT, keriput_result TEXT, kemerahan_result TEXT, bercak_hitam_result TEXT, jenis_kulit_result TEXT, date TEXT NOT NULL)',
      );
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<List<Map<String, dynamic>>> getSingleData(String table, List<String> column, String whereArgs) async {
    final db = await DBHelper.database();
    return db.query(table, columns: column, where: '${column[0]} = ?', whereArgs: [whereArgs]);
  }
}
