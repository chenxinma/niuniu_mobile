import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/homework.dart';
import 'package:niuniu/pvt/study/service/homework_service.dart';
import 'package:niuniu/pvt/study/service/subject_service.dart';
import 'package:time_range_picker/time_range_picker.dart';


void main() {
  runApp(NiuniuApp());
}
class Choice {
  const Choice({ this.title, this.icon });
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Homework', icon: Icons.book),
];


class NiuniuApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NiuNiu',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
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
            children: choices.map((Choice choice) => ChoiceCard(choice: choice))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class ChoiceCard extends StatefulWidget {
  const ChoiceCard({ Key key, this.choice }) : super(key: key);
  final Choice choice;

  @override
  State<ChoiceCard> createState() {
    if (choice.title == "Homework") {
      return _HomeworkCardState();
    }
    return null;
  }
}

class _HomeworkCardState extends State<ChoiceCard> {

  DateTime _selectedDate = DateTime.now();
  HomeworkService _homeworkService = HomeworkService();
  SubjectService _subjectService = SubjectService();
  Future<List> _subjects;
  Map<int, String> _homeworkTimeRange = {}; // for display
  Map<int, int> _homeworkIds = {};

  void _loadSubjects() {
    _subjects = _subjectService.subjects;
  }

  void _loadHomework(DateTime publishDate) async {
    var workTime = {};
    (await _subjects).forEach((s) {
      workTime[s.id] = "时间";
    });
    _homeworkIds.clear();
    var resp = await _homeworkService.loadHomework(publishDate);
    resp.forEach((sid, h) {
      if (h.completeTime != null) {
        workTime[sid] = _homeworkService.formatTimeRange(h);
      }
      _homeworkIds[sid] = h.id;
    });
    setState(() {
      workTime.forEach((key, value) {
        _homeworkTimeRange[key] = value;
      });
    });
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate, //选中的日期
      firstDate: DateTime(2020), //日期选择器上可选择的最早日期
      lastDate: DateTime(2030), //日期选择器上可选择的最晚日期
    ).then((result) {
      if (result != null) {
        setState(() {
          this._selectedDate = result;
        });
        _loadHomework(_selectedDate);
      }
    });
  }

  void _showTimePicker(int subjectId) async {
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
      start: TimeOfDay(hour: 15, minute: 0),
      end: TimeOfDay(hour: 21, minute: 0),
    );
    if (result != null) {
      var homework = _homeworkService.create(publishDate: _selectedDate,
          subjectId: subjectId, workTimeRange: result);
      int homeworkId = await _homeworkService.saveOnTimePicker(homework);
      setState(() {
        _homeworkIds[subjectId] = homeworkId;
        _homeworkTimeRange[subjectId] =
            _homeworkService.formatTimeRange(homework);
      });
    }
  }

  @override
  void initState() {
    _loadSubjects();
    _loadHomework(_selectedDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/homework.png"),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerRight,
                )),
            child: InkWell(
              key: Key("publishDateInkWell"),
              onTap: _showDatePicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "作业日:   ${formatDate(_selectedDate, [
                      yyyy,
                      "-",
                      mm,
                      "-",
                      dd
                    ])}",
                    textAlign: TextAlign.left,
                    key: Key("publishDateText"),
                  ),
                  Icon(Icons.calendar_today)
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: FutureBuilder<List>(
              future: _subjects,
              builder: (BuildContext context,
                  AsyncSnapshot<List> _subjects) {
                if (_subjects.hasData) {
                  int subjectSize = _subjects.data.length;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: subjectSize,
                    itemBuilder: (context, index) {
                      String s = _subjects.data[index].subject;
                      int id = _subjects.data[index].id;
                      return ListTile(
                        key: Key("homework_subject_$index"),
                        title: Text("$s"),
                        subtitle: Row(
                          children: <Widget>[
                            Text("${this._homeworkTimeRange[id]}"),
                          ],
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: () {
                          _showTimePicker(id);
                        },
                        onLongPress: () {
                          setState(() {
                            _homeworkTimeRange[id] = "时间";
                            _homeworkService.clearTime(id);
                          });
                        },
                      );
                    },
                  );
                } else {
                  return Text("加载中...");
                }
              },
            ),
          ),
        ],
      );
  }
}


