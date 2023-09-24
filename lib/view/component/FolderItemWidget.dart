import 'package:flutter/material.dart';

class CustomClickableContainer extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback onTap;

  CustomClickableContainer({
    required this.child,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  _CustomClickableContainerState createState() => _CustomClickableContainerState();
}

class _CustomClickableContainerState extends State<CustomClickableContainer> {
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
        color: isTapped ? widget.backgroundColor : Colors.transparent,
        child: widget.child,
      ),
    );
  }
}
