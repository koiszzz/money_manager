import 'package:flutter/material.dart';

class MyCButtonWidget extends StatefulWidget {
  const MyCButtonWidget({
    super.key,
    required this.text,
    this.flex = 1,
    required this.onTap,
  });
  final String text;
  final int flex;
  final void Function(String value) onTap;

  @override
  State<StatefulWidget> createState() {
    return _MyCButtonState();
  }
}

class _MyCButtonState extends State<MyCButtonWidget> {
  dynamic onTap = false;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: widget.flex,
      child: GestureDetector(
          onTapDown: (detail) {
            setState(() {
              onTap = true;
            });
          },
          onTapCancel: () {
            setState(() {
              onTap = false;
            });
          },
          onTapUp: (detail) {
            setState(() {
              onTap = false;
            });
          },
          onTap: () {
            widget.onTap(widget.text);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                color: onTap ? Colors.grey[300] : Colors.grey[100]),
            child: Text(
              widget.text,
              style: const TextStyle(fontSize: 18),
            ),
          )),
    );
  }
}
