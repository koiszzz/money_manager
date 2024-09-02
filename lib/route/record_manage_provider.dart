import 'package:flutter/material.dart';
import 'package:money_manager/base_service.dart';
import 'package:money_manager/database/db_helper.dart';
import 'package:money_manager/database/record_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

class RecordManageProvider extends ChangeNotifier {
  RecordManageProvider() {
    loadData();
  }
  bool isLoading = false;
  int _count = 0;
  RecordModel? _lastTrade;

  get count => _count;
  get lastTrade => _lastTrade;

  Future<List<RecordModel>> loadData() async {
    print('reload');
    final Database database = sl<DbHelper>().db;
    isLoading = true;
    List<RecordModel> list = (await database.query(RecordModel.tableTrade,
            orderBy: 'date desc', limit: 100))
        .map((r) => RecordModel.fromMap(r))
        .toList();
    isLoading = false;
    _count = list.length;
    _lastTrade = list.isNotEmpty ? list[_count - 1] : null;
    notifyListeners();
    return list;
  }

  Future<dynamic> saveOrUpdate(RecordModel data) async {
    final Database database = sl<DbHelper>().db;
    if (data.id != null && data.id!.isNotEmpty) {
      print('updated');
      await database.update(RecordModel.tableTrade, data.toMap(),
          where: 'id = "${data.id}"');
    } else {
      print('insert');
      data.id = const Uuid().v1();
      print(data.toMap());
      await database.insert(RecordModel.tableTrade, data.toMap());
    }
    await loadData();
    print('completed');
  }
}
