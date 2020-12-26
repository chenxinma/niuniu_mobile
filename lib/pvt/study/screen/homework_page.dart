import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:niuniu/pvt/study/entity/homework.dart';
import 'package:niuniu/pvt/study/screen/navigation_bar_builder.dart';
import 'package:niuniu/pvt/study/service/homework_service.dart';
import 'package:niuniu/pvt/study/service/subject_service.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeworkPage extends StatefulWidget {
  @override
  HomeworkState createState() => HomeworkState();
}

class HomeworkState extends State<HomeworkPage> with TickerProviderStateMixin {
  DateTime _selectedDate;
  Map<DateTime, List> _homeworkList = {};
  List<Homework> _selectedHomework = [];
  HomeworkService _homeworkService = HomeworkService();
  SubjectService _subjectService = SubjectService();
  Future<List> _subjects;
  CalendarController _calendarController;
  AnimationController _animationController;
  bool doDelete = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _loadSubjects();
    _selectedDate =
        DateTime.parse(formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd]))
            .toLocal();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _selectedDate =
        DateTime.parse(formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd]))
            .toLocal();

    _animationController.forward();
    super.initState();
  }

  void _loadSubjects() {
    _subjects = _subjectService.subjects;
  }

  void _showTimePicker(Homework homework) async {
    var _begin = homework.beginTime != null
        ? TimeOfDay.fromDateTime(homework.beginTime)
        : TimeOfDay.fromDateTime(DateTime.now());
    var _end = homework.completeTime != null
        ? TimeOfDay.fromDateTime(homework.completeTime)
        : TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30)));
    TimeRange result = await showTimeRangePicker(
      context: context,
      hideButtons: true,
      // hideTimes: true,
      ticks: 12,
      strokeWidth: 10,
      labels: [
        ClockLabel.fromTime(time: TimeOfDay(hour: 21, minute: 0), text: "睡觉")
      ],
      labelOffset: 40,
      start: _begin,
      end: _end,
    );
    if (result != null) {
      var _homework = _homeworkService.create(
          homeworkId: homework.id,
          publishDate: _selectedDate,
          subjectId: homework.subject.id,
          workTimeRange: result);
      await _homeworkService.saveOnTimePicker(_homework);
      await _flushSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Homework"),
      ),
      bottomNavigationBar:
          NavigationBarBuilder.create(context, NavigationBarBuilder.screens[0]),
      body: _buildContent(context),
    );
  }

  void _popHomeworkDelte(BuildContext context, int id) {
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
        var resp = _homeworkService.delete(id);
        resp.then((value) {
          _flushSelectedDate();
        });
      }
      _scaffoldKey.currentState.removeCurrentSnackBar();
    });
  }

  Future _flushSelectedDate() async {
    var homeworkList = await _homeworkService.loadHomework(_selectedDate);
    setState(() {
      _homeworkList[_selectedDate] = homeworkList;
      _selectedHomework = homeworkList;
      _calendarController.setSelectedDay(_selectedDate);
    });
    return homeworkList;
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildTableCalendar(),
        const SizedBox(height: 8.0),
        Container(
          padding: EdgeInsets.fromLTRB(16,8,0,8),
          color: Colors.grey[200],
          child: Row(
            children: <Widget>[
              Text("${formatDate(_selectedDate, [yyyy, "-", mm, "-", dd])}")
            ],
          ),
        ),
        Expanded(
          child: _buildHomeworkList(context),
        ),
      ],
    );
  }

  Widget _buildHomeworkList(BuildContext context) {
    return FutureBuilder<List>(
      future: _subjects,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          List<Homework> homeworkListItmes = _homeworkService.fill(
              _selectedHomework, snapshot.data, _selectedDate);
          return ListView(
            children: homeworkListItmes
                .map(
                  (h) => h.id != null
                      ? Slidable(
                          actionExtentRatio: 0.25,
                          actionPane: SlidableScrollActionPane(),
                          child: Container(
                            color: Colors.white,
                            child: ListTile(
                              title: Text("${h.subject.subject}"),
                              subtitle: Text('${h.timeLable}'),
                              trailing: Icon(Icons.access_time),
                              onTap: () {
                                _showTimePicker(h);
                              },
                              onLongPress:  () => _popHomeworkDelte(context, h.id),
                            ),
                          ),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: '删除',
                              color: Colors.red[300],
                              icon: Icons.delete,
                              onTap: () => _popHomeworkDelte(context, h.id),
                            ),
                          ],
                        )
                      : Container(
                          color: Colors.white,
                          child: ListTile(
                            title: Text("${h.subject.subject}"),
                            subtitle: Text('${h.timeLable}'),
                            trailing: Icon(Icons.access_time),
                            onTap: () {
                              _showTimePicker(h);
                            },
                          ),
                        ),
                )
                .toList(),
          );
        } else {
          return Text("加载中...");
        }
      },
    );
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      _selectedDate =
          DateTime.parse(formatDate(day, [yyyy, "-", mm, "-", dd])).toLocal();
      _selectedHomework = events.map((e) => e as Homework).toList();
    });
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    var homeworkList = _homeworkService.loadHomework2(first, last);
    homeworkList.then((e) {
      setState(() {
        e.forEach((k, v) {
          _homeworkList[k] = v;
        });
        if (_homeworkList.containsKey(_selectedDate)) {
          _homeworkList[_selectedDate].forEach((element) {
            _selectedHomework.add(element);
          });
        }
      });
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    var homeworkList = _homeworkService.loadHomework2(first, last);
    homeworkList.then((e) {
      setState(() {
        e.forEach((k, v) {
          _homeworkList[k] = v;
        });
      });
    });
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
      events: _homeworkList,
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.pink,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style:
                    TextStyle().copyWith(fontSize: 16.0, color: Colors.white),
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
}
