import 'package:flutter/material.dart';
import 'calculator.dart';

class EditRecordWidget extends StatefulWidget {
  const EditRecordWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EditRecordState();
  }
}

class _EditRecordState extends State<EditRecordWidget>
    with SingleTickerProviderStateMixin {
  List<FormItemModel> _items = [
    FormItemModel(
        label: '金额',
        type: FormItemType.number,
        selected: true,
        textController: TextEditingController(text: '0.00'),
        key: GlobalKey<MyCalculatorState>()),
    FormItemModel(
        label: '分类',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        label: '账户',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        label: '时间',
        type: FormItemType.dateTime,
        textController: TextEditingController()),
    FormItemModel(
        label: '成员',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        label: '商家',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        label: '项目',
        type: FormItemType.select,
        textController: TextEditingController()),
    FormItemModel(
        label: '备注',
        type: FormItemType.text,
        textController: TextEditingController()),
  ];
  late FormItemModel _selectedItem;
  bool _isBottomOpen = true;
  late Animation<double> _heightAnimation;
  late AnimationController _heightAnimationController;

  @override
  void initState() {
    super.initState();
    _selectedItem = _items.elementAt(0);
    _heightAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _heightAnimation =
        Tween<double>(begin: 0, end: 400).animate(_heightAnimationController);
    _heightAnimationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _heightAnimationController.dispose();
    _items.map((e) {
      e.textController.dispose();
    });
  }

  _closeBottom() {
    if (_selectedItem.key != null) {
      switch (_selectedItem.type) {
        case FormItemType.number:
          (_selectedItem.key as GlobalKey<MyCalculatorState>)
              .currentState
              ?.finishInput();
          break;
        default:
          break;
      }
    }
    setState(() {
      _isBottomOpen = false;
    });
    _heightAnimationController.reverse().whenComplete(() {});
  }

  _openBottom() {
    setState(() {
      _isBottomOpen = true;
    });
    _heightAnimationController.forward().whenComplete(() {});
  }

  _selectItem(FormItemModel item) {
    if (_heightAnimation.value == 0) {
      _openBottom();
    }
    if (_selectedItem != item) {
      if (_selectedItem.key != null) {
        (_selectedItem.key as GlobalKey<MyCalculatorState>)
            .currentState
            ?.finishInput();
      }
      setState(() {
        _selectedItem = item;
        _items = _items.map((e) {
          e.selected = e == _selectedItem;
          return e;
        }).toList();
      });
    }
  }

  _genBottomSheetWidget() {
    List<Widget> bottomChildren = [
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => _closeBottom(),
            child: Container(
              width: 60,
              height: _isBottomOpen ? 40 : 0,
              decoration: BoxDecoration(
                  border: const Border(
                      top: BorderSide(color: Colors.black12),
                      left: BorderSide(color: Colors.black12),
                      right: BorderSide(color: Colors.black12),
                      bottom: BorderSide.none),
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ]),
              child: const Icon(Icons.arrow_downward_rounded),
            ),
          )
        ],
      )
    ];
    switch (_selectedItem.type) {
      case FormItemType.number:
        bottomChildren.add(Flexible(
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ]),
            child: MyCalculatorWidget(
              key: _selectedItem.key,
              controller: _selectedItem.textController,
              // onChange: _calChange,
            ),
          ),
        ));
        break;
      default:
        bottomChildren.add(Flexible(
            child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ]),
          child: const Text('测试'),
        )));
    }
    Widget typeWidget =
        Column(mainAxisSize: MainAxisSize.max, children: bottomChildren);
    return typeWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记一笔')),
      body: Builder(
        builder: (context) {
          Widget typeWidget = _genBottomSheetWidget();
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      FormItemModel item = _items.elementAt(index);
                      // item.textController?.text = item.value;
                      return Container(
                        padding: const EdgeInsets.all(5),
                        color: item.selected ? Colors.grey.shade100 : null,
                        child: GestureDetector(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 20,
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Flexible(
                                  child: TextField(
                                key: UniqueKey(),
                                autofocus: item.selected,
                                readOnly: !item.showKeyBoard,
                                controller: item.textController,
                                textAlign: TextAlign.start,
                                onTap: () => _selectItem(item),
                                decoration: const InputDecoration(
                                    border: InputBorder.none),
                              )),
                            ],
                          ),
                          onTap: () => _selectItem(item),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: _items.length),
              ),
              _BottomContainer(animation: _heightAnimation, child: typeWidget),
            ],
          );
        },
      ),
    );
  }
}

enum FormItemType { number, select, text, date, time, dateTime }

class FormItemModel {
  FormItemModel({
    required this.label,
    required this.type,
    this.fontSize = 15,
    this.options,
    required this.textController,
    this.selected = false,
    this.key,
  });
  String label;
  FormItemType type;
  int fontSize;
  String? options;
  // String value;
  bool selected;
  TextEditingController textController;
  GlobalKey? key;

  bool get showKeyBoard {
    return type == FormItemType.text;
  }
}

class _BottomContainer extends AnimatedWidget {
  const _BottomContainer(
      {required Animation<double> animation, required this.child})
      : super(
          listenable: animation,
        );
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    Widget child = this.child;
    return Container(
      width: double.infinity,
      height: animation.value,
      color: Colors.black.withOpacity(0),
      child: child,
    );
  }
}
