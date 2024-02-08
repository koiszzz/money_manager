import 'package:flutter/material.dart';
import 'package:money_manager/database/db_provider.dart';

class MyHomeWidget extends StatefulWidget {
  const MyHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomeState();
  }
}

class _MyHomeState extends State<MyHomeWidget> {
  late DBProvider dbProvider;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: dbProvider.getRecords(),
        builder: (context, snapshot) {
          return Container(
            height: 500,
            child: Column(
              children: [
                Center(
                  child: Text('数量:${snapshot.data?.length}'),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('刷新')),
                Container(
                  height: 250,
                  child: ListView(
                    children: snapshot.data?.map((e) {
                          return Text('${e.amount}');
                        }).toList() ??
                        [const Text('没有数据')],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    dbProvider = DBProvider();
    super.initState();
  }
}
