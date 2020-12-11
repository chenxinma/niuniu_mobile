import 'package:flutter/material.dart';
import 'package:niuniu/pvt/study/screen/choice_card.dart';
import 'package:niuniu/pvt/study/util/choice.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(NiuniuApp()));
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Homework', icon: Icons.book),
  const Choice(title: 'Exercis', icon: Icons.school),
];

class NiuniuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NiuNiu',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimatedSplashScreen.withScreenFunction(
        splash: "images/icon_sed.png",
        screenFunction: () async {
          return DefaultTabController(
            length: choices.length,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("NiuNiu"),
                bottom: TabBar(
                  isScrollable: true,
                  tabs: choices.map((Choice choice) {
                    return Tab(
                      text: choice.title,
                      icon: Icon(choice.icon),
                    );
                  }).toList(),
                ),
              ),
              body: TabBarView(
                children: choices
                    .map((Choice choice) => ChoiceCard(choice: choice))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
