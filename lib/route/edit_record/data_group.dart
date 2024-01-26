import 'package:flutter/material.dart';

class DataGroupWidget extends StatefulWidget {
  const DataGroupWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DataGroupState();
  }
}

class _DataGroupState extends State<DataGroupWidget> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text('数据展示')],
    );
  }
}
