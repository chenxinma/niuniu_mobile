import 'package:flutter/material.dart';
import 'package:niuniu/pvt/study/screen/exercise_card.dart';
import 'package:niuniu/pvt/study/screen/homework_card.dart';
import 'package:niuniu/pvt/study/util/choice.dart';

class ChoiceCard extends StatefulWidget {
  const ChoiceCard({ Key key, this.choice }) : super(key: key);
  final Choice choice;

  @override
  State<ChoiceCard> createState() {
    if (choice.title == "Homework") {
      return HomeworkCardState();
    } else if (choice.title == "Exercis") {
      return ExerciseCardState();
    }
    return null;
  }
}