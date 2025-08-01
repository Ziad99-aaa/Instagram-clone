import 'package:flutter/material.dart';

class Responsive extends StatefulWidget {
  final myWebScreen;
  final myMobileScreen;
  const Responsive({
    super.key,
    required this.myWebScreen,
    required this.myMobileScreen,
  });
  @override
  State<Responsive> createState() => _RsponsiveState();
}

class _RsponsiveState extends State<Responsive> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (buildContext, boxConstraints) {
      if (boxConstraints.maxWidth > 600) {
        return widget.myWebScreen;
      } else {
        return widget.myMobileScreen;
      }
    });
  }
}
