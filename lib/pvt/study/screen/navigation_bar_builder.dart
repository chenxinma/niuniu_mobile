import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niuniu/pvt/study/util/screen_define.dart';

class NavigationBarBuilder {
  static final List<ScreenDefine> screens = [
    ScreenDefine(icon: Icons.book, title: "Homework", route: "/homework"),
    ScreenDefine(icon: Icons.school, title: "Exercise", route: "/exercise"),
  ];

  static Widget create(BuildContext context, ScreenDefine screen) {
    return BottomNavigationBar(
      items: screens
          .map((e) =>
              BottomNavigationBarItem(icon: Icon(e.icon), label: e.title))
          .toList(),
      currentIndex: screens.indexOf(screen),
      selectedItemColor: Colors.pinkAccent,
      onTap: (index) {
        Navigator.pushReplacementNamed(context, screens[index].route);
      },
    );
  }
}
