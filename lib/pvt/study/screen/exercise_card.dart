import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:niuniu/pvt/study/entity/exercise.dart';
import 'package:niuniu/pvt/study/screen/choice_card.dart';
import 'package:niuniu/pvt/study/service/exercise_service.dart';
import 'package:niuniu/pvt/study/service/subject_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_select/smart_select.dart';
import 'package:async/async.dart';

class ExerciseCardState extends State<ChoiceCard>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events = {};
  List<Exercise> _selectedEvents = [];
  CalendarController _calendarController;
  AnimationController _animationController;
  ExerciseService exerciseService = ExerciseService();
  var _selectedDate = DateTime.now();
  var _selectedGrade;
  final TextEditingController _titleController = new TextEditingController();
  SubjectService _subjectService = SubjectService();
  var _selectedSubject;
  var _subjects;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
    _subjects = _getSubjects();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildTableCalendar(),
        const SizedBox(height: 8.0),
        _buildButtons(),
        const SizedBox(height: 8.0),
        Expanded(child: _buildEventList()),
      ],
    );
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events.map((e) => e as Exercise).toList();
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    var exercises = exerciseService.findByApprovalDate(first, last);
    exercises.then((e) {
      setState(() {
        e.forEach((k, v) {
          _events[k] = v;
        });
      });
    });
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    var exercises = exerciseService.findByApprovalDate(first, last);
    exercises.then((e) {
      setState(() {
        e.forEach((k, v) {
          _events[k] = v;
        });
      });
    });
  }

  void _showExercisePanel() {
    _titleController.clear();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white54,
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      Text(
                        "${formatDate(_selectedDate, [
                          yyyy,
                          "-",
                          mm,
                          "-",
                          dd
                        ])}",
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )),
              const Divider(indent: 10),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    hintText: "Exercise or Quest Name",
                    prefixIcon: Icon(Icons.school)),
              ),
              SmartSelect<int>.single(
                title: '成绩',
                value: _selectedGrade,
                onChange: (state) =>
                    setState(() => _selectedGrade = state.value),
                choiceItems: S2Choice.listFrom<int, String>(
                  source: ["优⭐", "优", "良", "合格"],
                  value: (index, item) => index,
                  title: (index, item) => item,
                ),
                modalType: S2ModalType.popupDialog,
              ),
              FutureBuilder<List>(
                initialData: [],
                future: _subjects,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SmartSelect.single(
                      title: '课程',
                      value: _selectedSubject,
                      onChange: (state) =>
                          setState(() => _selectedSubject = state.value),
                      choiceItems: snapshot.data.map((s) => S2Choice(title: s.subject, value: s.id)).toList(),
                      modalType: S2ModalType.popupDialog,
                    );
                  } else {
                    return Text("加载中...");
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Column(children: <Widget>[
      FlatButton(
        child: Row(children: [Icon(Icons.add), Text("新增")]),
        color: Colors.black12,
        onPressed: _showExercisePanel,
      )
    ]);
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.title),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'zh_CN',
      calendarController: _calendarController,
      events: _events,
      builders: CalendarBuilders(
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Future<List> _getSubjects() async {
    return _subjectService.subjects;
  }
}
