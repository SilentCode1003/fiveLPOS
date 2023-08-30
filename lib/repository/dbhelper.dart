import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    return _database ?? await _initDatabase();

    // if (_database != null) return _database;
    // _database = await _initDatabase();
    // return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'posconfig.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute(
        'CREATE TABLE pos (posid int, posname varchar(10), serial varchar(20), min varchar(50), ptu varchar(50))');
    await db.execute(
        'CREATE TABLE branch (branchid varchar(5), branchname varchar(300), tin varchar(60), address varchar(300), logo TEXT)');
  }

  Future<int> insertItem(Map<String, dynamic> item, String tablename) async {
    Database db = await database;
    return await db.insert('$tablename', item);
  }
}
