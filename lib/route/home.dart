import 'package:flutter/material.dart';
import 'package:money_manager/route/record_manage_provider.dart';
import 'package:provider/provider.dart';

class MyHomeWidget extends StatelessWidget {
  const MyHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('${context.watch<RecordManageProvider>().count}'),
    );
  }
}
