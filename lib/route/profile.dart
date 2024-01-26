import 'package:flutter/material.dart';

class MyProfileWidget extends StatefulWidget {
  const MyProfileWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyProfileState();
  }
}

class _MyProfileState extends State<MyProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return const Text('档案列表');
  }
}
