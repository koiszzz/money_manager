import 'package:flutter/material.dart';

class CalculatorModel extends ChangeNotifier implements BottomModel {
  @override
  initInput(String input) {
    curInput = input;
  }

  Iterable<RegExpMatch> _getNumber(String input) {
    RegExp groupNum = RegExp(
        r'(?<opt>[+-]*)((?<number>([1-9]{1}\d*)|([0]{1}))(?<digtal>\.(\d)*)?)?',
        dotAll: true);
    Iterable<RegExpMatch> list = groupNum.allMatches(input);
    return list;
  }

  String _calNumber() {
    Iterable<RegExpMatch> list = _getNumber(curInput);
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
    return all.toStringAsFixed(2);
  }

  dealWithSignal(String value) {
    if (value == 'C') {
      result = '0.00';
      curInput = '0.00';
      return;
    }
    if (value == 'X') {
      if (curInput.isEmpty) {
        curInput = '0.00';
        result = '0.00';
        return;
      } else {
        curInput = curInput.substring(0, curInput.length - 1);
        result = curInput.isEmpty ? '0.00' : _calNumber();
        return;
      }
    }
    if (value == '=') {
      curInput = _calNumber();
      result = _calNumber();
      return;
    }
    if (curInput == '0.00' || curInput.isEmpty) {
      if (value == '.') {
        curInput = '0.';
        result = '0.00';
        return;
      } else if (value == '+' || value == '-') {
        curInput = '0.00';
        result = '0.00';
        return;
      } else {
        curInput = value;
        result = curInput;
        return;
      }
    }
    String input = curInput + value;
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
    result = _calNumber();
    curInput = output;
  }

  @override
  String curInput = '';

  @override
  String result = '';
}

abstract class BottomModel {
  String result = '';
  String curInput = '';

  void initInput(String input);
}
