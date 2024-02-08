import 'package:flutter/material.dart';
import 'package:money_manager/route/calculator/calculator_provider.dart';
import 'package:money_manager/route/calculator/calculator_button.dart';
import 'package:provider/provider.dart';

class CalculatorStateless extends StatelessWidget {
  CalculatorStateless({super.key, this.onChange});
  final Function(String value)? onChange;
  final List<List<CBtnModel>> list = [
    [
      CBtnModel(text: '1'),
      CBtnModel(text: '2'),
      CBtnModel(text: '3'),
      CBtnModel(text: 'C')
    ],
    [
      CBtnModel(text: '4'),
      CBtnModel(text: '5'),
      CBtnModel(text: '6'),
      CBtnModel(text: '+')
    ],
    [
      CBtnModel(text: '7'),
      CBtnModel(text: '8'),
      CBtnModel(text: '9'),
      CBtnModel(text: '-')
    ],
    [
      CBtnModel(text: '.'),
      CBtnModel(text: '0'),
      CBtnModel(text: 'X'),
      CBtnModel(text: '=')
    ],
  ];

  @override
  Widget build(BuildContext context) {
    CalculatorModel calculator = context.watch<CalculatorModel>();
    return Container(
      width: double.infinity,
      color: Colors.redAccent,
      child: Column(
          mainAxisSize: MainAxisSize.max,
          children: list.map((e) {
            List<Widget> children = e.map((f) {
              return MyCButtonWidget(
                text: f.text,
                flex: f.flex,
                onTap: (value) {
                  calculator.dealWithSignal(value);
                  onChange!(calculator.curInput);
                },
              );
            }).toList();
            return Expanded(
                child: Container(
              color: Colors.greenAccent,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: children,
              ),
            ));
          }).toList()),
    );
  }
}

class CBtnModel {
  CBtnModel({required this.text, this.flex = 1});
  String text;
  int flex;
}
