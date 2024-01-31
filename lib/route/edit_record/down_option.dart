import 'package:flutter/material.dart';

class MyDownOptionWidget extends StatefulWidget {
  const MyDownOptionWidget(
      {super.key, this.controller, required this.dataType});
  final TextEditingController? controller;
  final String dataType;

  @override
  State<StatefulWidget> createState() {
    return MyDownOptionState();
  }
}

class MyDownOptionState extends State<MyDownOptionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      child: Text(widget.dataType),
    );
  }
}
