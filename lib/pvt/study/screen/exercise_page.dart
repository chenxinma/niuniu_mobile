import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:niuniu/pvt/study/entity/exercise.dart';
import 'package:niuniu/pvt/study/entity/subject.dart';
import 'package:niuniu/pvt/study/screen/navigation_bar_builder.dart';
import 'package:niuniu/pvt/study/service/exercise_service.dart';
import 'package:niuniu/pvt/study/service/subject_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smart_select/smart_select.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ExercisePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ExerciseState();
}

class ExerciseState extends State<ExercisePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events = {};
  List<Exercise> _selectedEvents = [];
  CalendarController _calendarController;
  AnimationController _animationController;
  ExerciseService exerciseService = ExerciseService();
  DateTime _selectedDate;
  int _selectedGrade;
  final TextEditingController _titleController = new TextEditingController();
  SubjectService _subjectService = SubjectService();
  int _selectedSubject;
  var _subjects;
  final List<String> grades = ["优⭐", "优", "良", "合格"];
  bool doDelete = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _selectedDate =
        DateTime.parse(formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd]))
            .toLocal();

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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Exercise"),
      ),
      bottomNavigationBar:
          NavigationBarBuilder.create(context, NavigationBarBuilder.screens[1]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showExercisePanel();
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: <Widget>[
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(context),
          ),
        ],
      ),
    );
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      _selectedDate =
          DateTime.parse(formatDate(day, [yyyy, "-", mm, "-", dd])).toLocal();
      _selectedEvents = events.map((e) => e as Exercise).toList();
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    var exercises = exerciseService.findByApprovalDateRange(first, last);
    exercises.then((e) {
      setState(() {
        e.forEach((k, v) {
          _events[k] = v;
        });
        _selectedEvents.clear();
      });
    });
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    var exercises = exerciseService.findByApprovalDateRange(first, last);
    exercises.then((e) {
      _selectedEvents.clear();
      setState(() {
        e.forEach((k, v) {
          _events[k] = v;
        });
        if (_events.containsKey(_selectedDate)) {
          _events[_selectedDate].forEach((element) {
            _selectedEvents.add(element);
          });
        }
      });
    });
  }

  void _showExercisePanel([Exercise oldExercise]) {
    if (oldExercise == null) {
      setState(() {
        _titleController.clear();
        _selectedSubject = 1;
        _selectedGrade = 1;
      });
    } else {
      setState(() {
        _titleController.text = oldExercise.title;
        _selectedSubject = oldExercise.subject.id;
        _selectedGrade = grades.indexOf(oldExercise.grade);
      });
    }

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          children: <Widget>[
            Row(
              children: [
                Icon(Icons.calendar_today),
                Text(
                  "${formatDate(_selectedDate, [yyyy, "-", mm, "-", dd])}",
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            const Divider(),
            TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value.isEmpty) {
                  return '标题必须输入哦！';
                }
                return null;
              },
              decoration: InputDecoration(
                  hintText: "Exercise or Quest Name *",
                  prefixIcon: Icon(Icons.school)),
            ),
            SmartSelect<int>.single(
              title: '成绩',
              value: _selectedGrade,
              onChange: (state) => setState(() => _selectedGrade = state.value),
              choiceItems: S2Choice.listFrom<int, String>(
                source: grades,
                value: (index, item) => index,
                title: (index, item) => item,
              ),
              modalType: S2ModalType.fullPage,
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
                    choiceItems: snapshot.data
                        .map((s) => S2Choice(title: s.subject, value: s.id))
                        .toList(),
                    modalType: S2ModalType.fullPage,
                  );
                } else {
                  return Text("加载中...");
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                  color: Colors.pink,
                  textColor: Colors.white,
                  onPressed: () {
                    int _id;
                    if (oldExercise != null) {
                      _id = oldExercise.id;
                    }
                    Exercise exercise = Exercise(
                        id: _id,
                        approvalDate: _selectedDate,
                        title: _titleController.text,
                        grade: grades[_selectedGrade]);
                    if (oldExercise != null) {
                      // update subject
                      exercise.subject = oldExercise.subject;
                      exercise.newSubjectId = _selectedSubject;
                    } else {
                      // new create
                      exercise.subject = Subject(id: _selectedSubject);
                    }

                    var resp = exerciseService.save(exercise);
                    resp.then((value) {
                      _flushToday();
                      Navigator.pop(context, true);
                    });
                  },
                  child: Row(
                    children: <Widget>[Icon(Icons.save), const Text('保存')],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _flushToday() async {
    var exercises = await exerciseService.findByApprovalDate(_selectedDate);
    setState(() {
      _events[_selectedDate] = exercises;
      _selectedEvents = exercises;
      _calendarController.setSelectedDay(_selectedDate);
    });
  }

  void _showSnackBar(BuildContext context, int id) {
    doDelete = true;
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('删除'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            doDelete = false;
          },
        ),
      ),
    );
    Future.delayed(Duration(seconds: 1, microseconds: 500), () {
      if (doDelete) {
        var resp = exerciseService.delete(id);
        resp.then((value) {
          _flushToday();
        });
      }
      _scaffoldKey.currentState.removeCurrentSnackBar();
    });
  }

  Widget _buildEventList(BuildContext context) {
    return ListView(
      children: _selectedEvents
          .map(
            (event) => Slidable(
              key: Key("event_${event.id}"),
              actionExtentRatio: 0.25,
              actionPane: SlidableScrollActionPane(),
              child: Container(
                color: Colors.white,
                child: ListTile(
                  title: Text("${event.title}"),
                  subtitle: Text('${event.grade}'),
                  onTap: () {
                    _showExercisePanel(event);
                  },
                ),
              ),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: '删除',
                  color: Colors.red[300],
                  icon: Icons.delete,
                  onTap: () => _showSnackBar(context, event.id),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: 'zh_CN',
      availableCalendarFormats: const {
        CalendarFormat.month: 'Compact',
        CalendarFormat.week: 'All',
      },
      initialCalendarFormat: CalendarFormat.week,
      calendarController: _calendarController,
      events: _events,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.pink[100],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.pink[200],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
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
