import 'package:flutter/material.dart';
import 'package:money_manager/database/db_provider.dart';
import 'package:money_manager/database/record_model.dart';

class EditRecordModel extends ChangeNotifier {
  DBProvider dbProvider = DBProvider();
  bool bottomOpen;
  final List<FormItemModel> items = [
    FormItemModel(
        id: 'amount',
        label: '金额',
        type: FormItemType.number,
        selected: true,
        textController: TextEditingController(text: '0.00')),
    FormItemModel(
        id: 'type',
        label: '分类',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        id: 'account',
        label: '账户',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        id: 'date',
        label: '时间',
        type: FormItemType.dateTime,
        textController: TextEditingController()),
    FormItemModel(
        id: 'involves',
        label: '成员',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        id: 'merchant',
        label: '商家',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        id: 'project',
        label: '项目',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        id: 'desc',
        label: '备注',
        type: FormItemType.text,
        readonly: false,
        textController: TextEditingController()),
  ];
  RecordModel record;
  EditRecordModel({required this.bottomOpen, required this.record}) {
    Map map = record.toMap();
    items.map((e) {
      e.textController.text = map[e.id];
    });
  }

  selectItem(int index) {
    for (int i = 0; i < items.length; i++) {
      if (index == i) {
        items[i].selected = true;
      } else {
        items[i].selected = false;
      }
    }
    notifyListeners();
  }

  TextEditingController? get selectedController {
    FormItemModel? item;
    for (int i = 0; i < items.length; i++) {
      if (items[i].selected) {
        item = items[i];
        break;
      }
    }
    return item?.textController;
  }

  FormItemModel? get selectedItem {
    FormItemModel? item;
    for (int i = 0; i < items.length; i++) {
      if (items[i].selected) {
        item = items[i];
        break;
      }
    }
    return item;
  }

  toggleBottom(bool? state) {
    if (state == null) {
      bottomOpen = !bottomOpen;
    } else {
      bottomOpen = state;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    items.map((e) => e.textController.dispose());
  }

  save() async {
    Map<String, dynamic> m = {};
    for (FormItemModel e in items) {
      m[e.id] = e.textController.text;
    }
    print(m);
    record.update(m);
    await dbProvider.saveRecord(record);
  }
}

class FormItemModel {
  FormItemModel({
    required this.id,
    required this.label,
    required this.type,
    this.fontSize = 15,
    this.options,
    required this.textController,
    this.selected = false,
    this.readonly = true,
    this.key,
  });
  String id;
  String label;
  FormItemType type;
  int fontSize;
  String? options;
  // String value;
  bool selected;
  bool readonly;
  TextEditingController textController;
  GlobalKey? key;

  bool get showKeyBoard {
    return type == FormItemType.text;
  }
}

enum FormItemType { number, select, text, date, time, dateTime }
