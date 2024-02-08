import 'package:flutter/foundation.dart';
import 'package:money_manager/database/record_model.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uuid/uuid.dart';

class DBProvider {
  static final DBProvider _singleton = DBProvider._internal();

  factory DBProvider() {
    return _singleton;
  }

  DBProvider._internal();

  static Database? _db;

  Future<Database?> get db async {
    if (kIsWeb) {
      // ignore: invalid_use_of_visible_for_testing_member
      if (databaseFactoryOrNull == null) {
        databaseFactory = databaseFactoryFfiWeb;
      }
    }
    _db ??= await _initDB();
    return _db;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'money.db');
    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // 创建Table
  Future _onCreate(Database db, int version) async {
    print('database init');
    return await db.execute("CREATE TABLE trade_record ("
        "id TEXT primary key,"
        "amount REAL,"
        "date NUMERIC,"
        "type TEXT,"
        "typeId TEXT,"
        "account TEXT,"
        "accountId TEXT,"
        "parentTypeId TEXT,"
        "involves TEXT,"
        "toAccount TEXT,"
        "toAccountId TEXT,"
        "project TEXT,"
        "merchant TEXT,"
        "merchantId TEXT,"
        "desc TEXT"
        ")");
  }

  // 更新Table
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {}
  // 查询列表
  Future<RecordModel?> getRecordById(String id) async {
    final Database? database = await db;
    List<Map<String, dynamic>> maps =
        await database!.query('trade_record', where: 'id = "$id"');
    if (maps.isNotEmpty) {
      return RecordModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // 查询列表
  Future<List<RecordModel>> getRecords() async {
    final Database? database = await db;
    List<Map<String, dynamic>> maps = await database!.query('trade_record');
    try {
      List<RecordModel> list = maps.map((e) {
        return RecordModel.fromMap(e);
      }).toList();
      return list;
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return [];
    }
  }

  Future<int> saveRecord(RecordModel data) async {
    final Database? database = await db;
    if (data.id != null && data.id!.isNotEmpty) {
      return await database!
          .update('trade_record', data.toMap(), where: 'id = "${data.id}"');
    } else {
      data.id = const Uuid().v1();
      return await database!.insert('trade_record', data.toMap());
    }
  }
}
