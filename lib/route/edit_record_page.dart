import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/base_service.dart';
import 'package:money_manager/database/record_model.dart';
import 'package:money_manager/route/record_manage_provider.dart';
import 'package:provider/provider.dart';

class EditRecordPage extends StatelessWidget {
  static String routeName = '/editRecord';
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();
  final TextEditingController accountCtrl = TextEditingController();
  final TextEditingController toAccountCtrl = TextEditingController();
  final TextEditingController datetimeCtrl = TextEditingController();
  final TextEditingController ivCtrl = TextEditingController();
  final TextEditingController merchantCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController proCtrl = TextEditingController();

  EditRecordPage({super.key});

  save(context) async {
    Map<String, dynamic> m = {};
    m['amount'] = amountCtrl.value.text;
    sl<RecordManageProvider>().saveOrUpdate(RecordModel.fromMap(m));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecordManageProvider>.value(
      value: sl<RecordManageProvider>(),
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                    child: Text(
                      '金额',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                          controller: amountCtrl,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^(\d+)?\.?\d{0,2}'))
                      ]))
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                    child: Text(
                      '账户',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: accountCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ))
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                    child: Text(
                      '时间',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: datetimeCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ))
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                    child: Text(
                      '成员',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: ivCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ))
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                    child: Text(
                      '备注',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ))
                ],
              ),
              Row(
                children: [
                  Consumer<RecordManageProvider>(
                      builder: (cxt, manager, child) => ElevatedButton(
                          onPressed: () {
                            save(context);
                          },
                          child: const Text('保存')))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
