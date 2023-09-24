import 'package:flutter/material.dart';

class ColorBgContainer extends StatefulWidget {
  final Widget child;
  final Color tagDownColor;
  final Color tagUpColor;
  final VoidCallback onTap;

  ColorBgContainer({
    required this.child,
    required this.tagUpColor,
    required this.tagDownColor,
    required this.onTap,
  });

  @override
  _ColorBgContainerState createState() => _ColorBgContainerState();
}

class _ColorBgContainerState extends State<ColorBgContainer> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isTapped = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isTapped = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          isTapped = false;
        });
      },
      child: Container(
        color: isTapped ? widget.tagDownColor : widget.tagUpColor,
        child: widget.child,
      ),
    );
  }
}
