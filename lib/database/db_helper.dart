import 'package:flutter/foundation.dart';
import 'package:money_manager/database/record_model.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DbHelper {
  DbHelper();
  late Database db;

  Future<void> initDB() async {
    if (kIsWeb) {
      // ignore: invalid_use_of_visible_for_testing_member
      if (databaseFactoryOrNull == null) {
        databaseFactory = databaseFactoryFfiWeb;
      }
    }
    String path = join(await getDatabasesPath(), 'money.db');
    db = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // 创建Table
  Future _onCreate(Database db, int version) async {
    print('database init');
    return await db.execute(RecordModel.create());
  }

  // 更新Table
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}
}
