import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider _singleton = DBProvider._internal();

  factory DBProvider() {
    return _singleton;
  }

  DBProvider._internal();

  static Database? _db;

  Future<Database?> get db async {
    _db ??= await _initDB();
    return _db;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'dbName');
    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  ///
  /// 创建Table
  ///
  Future _onCreate(Database db, int version) async {
    return await db.execute("CREATE TABLE User ("
        "id integer primary key AUTOINCREMENT,"
        "name TEXT,"
        "age TEXT,"
        "sex integer"
        ")");
  }

  ///
  /// 更新Table
  ///
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
