import 'package:flutter/material.dart';
import 'package:money_manager/base_service.dart';
import 'package:money_manager/route/edit_record_page.dart';
import 'package:money_manager/route/profile.dart';
import 'package:money_manager/route/record_manage_provider.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key, required this.title});
  static String routeName = '/';
  final String title;

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecordManageProvider>.value(
      value: sl<RecordManageProvider>(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            MyHomeWidget(),
            MyProfileWidget(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            currentIndex: _currentIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.ac_unit_sharp), label: '档案'),
            ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, EditRecordPage.routeName,
                arguments: {"id": ''});
          },
          tooltip: '记一笔',
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
