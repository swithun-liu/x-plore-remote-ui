import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class CustomAnimatedSize extends StatefulWidget {
  final Widget child;
  bool open;
  bool lastOpen;

  CustomAnimatedSize(this.child, this.lastOpen, this.open, {Key? key}) : super(key: ValueKey(open));

  @override
  _CustomAnimatedSizeState createState() => _CustomAnimatedSizeState();
}

class _CustomAnimatedSizeState extends State<CustomAnimatedSize>
    with SingleTickerProviderStateMixin {
  final double start = 200;
  final double end = 300;

  bool checked = false;

  late double _width;

  @override
  void initState() {
    if (widget.lastOpen) {
      _width = end;
    } else {
      _width = start;
    }
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setState(() {
        if (widget.open) {
          _width = end;
        } else {
          _width = start;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // _buildSwitch(),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: checked ? Curves.easeOut : Curves.easeIn,
          alignment: const Alignment(0, 0),
          child: Container(
            height: _width,
            width: 300,
            alignment: Alignment.center,
            color: Colors.blue,
            child: widget.child,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch() => fluent.ToggleSwitch(
        checked: checked,
        onChanged: (v) {
          setState(() {
            checked = v;
            _width = v ? end : start;
          });
        },
      );
}
