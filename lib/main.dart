import 'package:flutter/material.dart';
import 'package:money_manager/base_service.dart';
import 'package:money_manager/route/edit_record_page.dart';
import 'package:money_manager/route/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        MyMainPage.routeName: (context) =>
            const MyMainPage(title: 'Flutter Demo Home Page'),
        EditRecordPage.routeName: (context) => EditRecordPage()
      },
    );
  }
}
