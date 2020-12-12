import 'package:flutter/material.dart';

class ScreenDefine {
  const ScreenDefine({this.title, this.icon, this.route});
  final String title;
  final IconData icon;
  final String route;

  @override
  int get hashCode => this.title.hashCode & this.route.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ScreenDefine) {
      return (other).hashCode == this.hashCode;
    }
    return super == other;
  }
}
