import 'package:flutter/material.dart';

class MyHomeWidget extends StatefulWidget {
  const MyHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomeState();
  }
}

class _MyHomeState extends State<MyHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text('首页')],
    );
  }
}
