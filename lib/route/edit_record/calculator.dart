import 'package:flutter/material.dart';
import 'calculator_button.dart';

class MyCalculatorWidget extends StatefulWidget {
  const MyCalculatorWidget({super.key, this.controller});
  final TextEditingController? controller;

  @override
  State<StatefulWidget> createState() {
    return MyCalculatorState();
  }
}

class MyCalculatorState extends State<MyCalculatorWidget> {
  List<List<CBtnModel>> list = [
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
  String _cashInput = '';

  @override
  void initState() {
    super.initState();
    if (widget.controller?.text != '0.00') {
      _cashInput = widget.controller?.text ?? '';
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  finishInput() {
    _calNumber();
  }

  Iterable<RegExpMatch> _getNumber(String input) {
    RegExp groupNum = RegExp(
        r'(?<opt>[+-]*)((?<number>([1-9]{1}\d*)|([0]{1}))(?<digtal>\.(\d)*)?)?',
        dotAll: true);
    Iterable<RegExpMatch> list = groupNum.allMatches(input);
    return list;
  }

  _calNumber() {
    Iterable<RegExpMatch> list = _getNumber(_cashInput);
    double all = 0;
    for (RegExpMatch e in list) {
      String opt = e.namedGroup('opt') ?? '';
      String number = e.namedGroup('number') ?? '';
      String digtal = e.namedGroup('digtal') ?? '';
      digtal = digtal.isEmpty
          ? ''
          : digtal.substring(0, digtal.length > 2 ? 3 : digtal.length);
      if (number.isNotEmpty) {
        switch (opt) {
          case '-':
            all -= double.parse('$number$digtal');
            break;
          default:
            all += double.parse('$number$digtal');
            break;
        }
      }
    }
    _cashInput = all.toStringAsFixed(2);
    widget.controller?.text = _cashInput;
  }

  _dealWithTap(String value) {
    if (value == 'C') {
      _cashInput = '';
      widget.controller?.text = '0.00';
      return;
    }
    if (value == 'X') {
      if (_cashInput.isEmpty) {
        _cashInput = '';
        widget.controller?.text = '0.00';
        return;
      } else {
        _cashInput = _cashInput.substring(0, _cashInput.length - 1);
        widget.controller?.text = _cashInput.isEmpty ? '0.00' : _cashInput;
        return;
      }
    }
    if (value == '=') {
      _calNumber();
      return;
    }
    String input = _cashInput + value;
    Iterable<RegExpMatch> list = _getNumber(input);
    String output = '';
    for (RegExpMatch e in list) {
      String opt = e.namedGroup('opt') ?? '';
      String number = e.namedGroup('number') ?? '';
      String digtal = e.namedGroup('digtal') ?? '';
      digtal = digtal.isEmpty
          ? ''
          : digtal.substring(0, digtal.length > 2 ? 3 : digtal.length);
      if (opt.isEmpty && number.isEmpty) {
        continue;
      } else if (number.isEmpty) {
        output += opt.substring(opt.length - 1);
      } else if (opt.isEmpty) {
        output += number + digtal;
      } else {
        output += '${opt.substring(opt.length - 1)}$number$digtal';
      }
    }
    widget.controller?.text = output;
    _cashInput = output;
  }

  @override
  Widget build(BuildContext context) {
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
                  _dealWithTap(value);
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
