import 'package:flutter/material.dart';
import 'package:niuniu/pvt/study/screen/exercise_page.dart';
import 'package:niuniu/pvt/study/screen/homework_page.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(NiuniuApp()));
}

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
        splash: 'images/icon_sed.png',
        screenFunction: () async {
          return HomeworkPage();
        },
        splashTransition: SplashTransition.fadeTransition,
      ),
      // initialRoute: '/homework',
      routes: {
        '/homework': (BuildContext context) => HomeworkPage(),
        '/exercise': (BuildContext context) => ExercisePage(),
      },
    );
  }
}
