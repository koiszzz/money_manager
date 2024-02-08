import 'package:flutter/material.dart';
import 'package:money_manager/database/record_model.dart';
import 'package:money_manager/route/calculator/calculator_provider.dart';
import 'package:money_manager/route/calculator/calculator_stateless.dart';
import 'package:money_manager/route/edit_record/edit_record_provider.dart';
import 'package:provider/provider.dart';

class EditRecordStateless extends StatelessWidget {
  static String routeName = '/editRecord';
  const EditRecordStateless({super.key});

  @override
  Widget build(BuildContext context) {
    final agrs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final data = RecordModel.fromMap(agrs);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EditRecordModel(bottomOpen: true, record: data),
        ),
        ChangeNotifierProvider(create: (_) => CalculatorModel()),
      ],
      child: _EditPage(),
    );
  }
}

class _EditPage extends StatelessWidget {
  _selectItem(int index, EditRecordModel editRecord, BuildContext context) {
    BottomModel? bottomModel;
    switch (editRecord.selectedItem?.type) {
      case FormItemType.number:
        bottomModel = context.read<CalculatorModel>();
        bottomModel.curInput = editRecord.selectedController?.text ?? '';
        break;
      default:
      // do nothong
    }
    if (bottomModel != null) {
      editRecord.selectedController?.text = bottomModel.result;
      bottomModel.curInput = bottomModel.result;
    }
    editRecord.selectItem(index);
    editRecord.toggleBottom(true);
  }

  _closeBottom(EditRecordModel editRecord, BuildContext context) {
    BottomModel? bottomModel;
    switch (editRecord.selectedItem?.type) {
      case FormItemType.number:
        bottomModel = context.read<CalculatorModel>();
        bottomModel.curInput = editRecord.selectedController?.text ?? '';
        break;
      default:
      // do nothong
    }
    if (bottomModel != null) {
      editRecord.selectedController?.text = bottomModel.result;
      bottomModel.curInput = bottomModel.result;
    }
    editRecord.toggleBottom(false);
  }

  _buildBottomWidget(EditRecordModel editRecord) {
    switch (editRecord.selectedItem?.type) {
      case FormItemType.number:
        return CalculatorStateless(
          onChange: (value) {
            editRecord.selectedController?.text = value;
          },
        );
      default:
        return Text('未定义${editRecord.selectedItem?.type}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记一笔'),
      ),
      body: Builder(builder: (context) {
        EditRecordModel editRecord = context.watch<EditRecordModel>();
        var borderDecoration = BoxDecoration(
            border: Border.all(width: 0, color: Colors.white.withOpacity(0)),
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ]);
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: ListView.separated(
                itemBuilder: ((context, index) {
                  var item = editRecord.items[index];
                  return GestureDetector(
                    onTap: () => _selectItem(index, editRecord, context),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      color: item.selected ? Colors.black12 : Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.add,
                            size: 20,
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                              child: TextField(
                            // 这边需要添加key, 不然刷新组件时可能会丢失focus状态或是点击父组件无法实现focus
                            key: UniqueKey(),
                            autofocus: item.selected,
                            readOnly: item.readonly,
                            controller: item.textController,
                            onTap: () =>
                                _selectItem(index, editRecord, context),
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                          ))
                        ],
                      ),
                    ),
                  );
                }),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
                itemCount: editRecord.items.length,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(0),
              // decoration: borderDecoration,
              child: editRecord.bottomOpen
                  ? Container(
                      height: 400,
                      color: Colors.white.withOpacity(0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => _closeBottom(editRecord, context),
                                child: Container(
                                  width: 60,
                                  height: editRecord.bottomOpen ? 40 : 0,
                                  decoration: borderDecoration,
                                  child:
                                      const Icon(Icons.arrow_downward_rounded),
                                ),
                              )
                            ],
                          ),
                          Flexible(
                            child: Container(
                                decoration: borderDecoration,
                                child: _buildBottomWidget(editRecord)),
                          )
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                            onPressed: () {
                              try {
                                editRecord.save();
                                Navigator.pop(context, true);
                              } catch (e, s) {
                                print(e);
                                print(s);
                              }
                            },
                            child: const Text('保存'))
                      ],
                    ),
            )
          ],
        );
      }),
    );
  }
}
