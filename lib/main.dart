import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:time_range_picker/time_range_picker.dart';

import 'action.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NiuNiu',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'NiuNiu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Homework'),
    // Tab(text: 'Exercise'),
    // Tab(text: 'Reward'),
  ];
  bool _offstage = true;
  DateTime _selectedDate = DateTime.now();
  Subject _subjectStub = Subject();
  Homework _homeworkStub = Homework();
  Map<int, dynamic> _homeworkCompleted = {};

  void _loadHomework() async {
    List<dynamic> subjects;
    if (_subjectStub.subjectsCache == null) {
      subjects = await _subjectStub.subjects;
      _subjectStub.cache(subjects);
    } else {
      subjects = _subjectStub.subjectsCache;
    }
    var completeTimes = {};
    subjects.forEach((s) {
      completeTimes[s['id']] = "完成时间";
    });

    var resp = await _homeworkStub.loadHomeworks(_selectedDate);
    resp.data.forEach((element) {
      int sid = element['subject']['id'];
      if (element['completeTime'] != null) {
        var ct = DateTime.parse(element['completeTime']);
        completeTimes[sid] = formatDate(ct, [hh, ":", nn, " ", am]);
      }
    });
    Future.delayed(
        Duration.zero,
        () => setState(() {
              completeTimes.forEach((key, value) {
                _homeworkCompleted[key] = value;
              });
              _offstage = true;
            }));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration.zero,
        () => setState(() {
              _loadHomework();
            }));
  }

  void _showDatePicker() {
    //获取异步方法里面的值的第一种方式：then
    showDatePicker(
      //如下四个参数为必填参数
      context: context,
      initialDate: _selectedDate, //选中的日期
      firstDate: DateTime(2020), //日期选择器上可选择的最早日期
      lastDate: DateTime(2030), //日期选择器上可选择的最晚日期
    ).then((result) {
      if (result != null) {
        setState(() {
          this._selectedDate = result;
          _loadHomework();
          _offstage = true;
        });
      }
    });
  }

  void _showTimePicker(int subjectId) async {
    // var result =
    //     await showTimePicker(context: context, initialTime: TimeOfDay.now());
    // if (result != null) {
    //   var resp = _homeworkStub.saveOnTimePicker(subjectId, result);
    //   resp.then((value) {
    //     setState(() {
    //       _homeworkCompleted[subjectId] = result.format(context);
    //     });
    //   });
    // }
    TimeRange result = await showTimeRangePicker(
      context: context,
      hideButtons: true,
      // hideTimes: true,
      ticks: 12,
      strokeWidth: 10,
      labels: [
        ClockLabel.fromTime(time: TimeOfDay(hour: 15, minute: 0), text: "回家"),
        ClockLabel.fromTime(time: TimeOfDay(hour: 21, minute: 0), text: "睡觉")
      ],
      labelOffset: 40,
      start: TimeOfDay(hour: 15, minute: 0),
      end: TimeOfDay(hour: 21, minute: 0),
      disabledTime: TimeRange(
          startTime: TimeOfDay(hour: 23, minute: 0),
          endTime: TimeOfDay(hour: 14, minute: 0)),
      disabledColor: Colors.red.withOpacity(0.5),
    );
    if (result != null) {
      var resp = await _homeworkStub.saveOnTimePicker(subjectId, result);
      if (resp.statusCode == 200) {
        setState(() {
          _homeworkCompleted[subjectId] = result.endTime.format(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: myTabs,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 16.0),
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle: TextStyle(fontSize: 12.0),
          ),
        ),
        body: TabBarView(
          children: [
            Tab(
              child: Column(
                children: <Widget>[
                  Offstage(
                    offstage: _offstage,
                    child: LinearProgressIndicator(),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage("images/homework.png"),
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.centerRight,
                    )),
                    child: InkWell(
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
                              textAlign: TextAlign.left),
                          Icon(Icons.calendar_today)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: FutureBuilder<List>(
                      future: _subjectStub.subjects,
                      builder: (BuildContext context,
                          AsyncSnapshot<List> _subjects) {
                        if (_subjects.hasData) {
                          int subjectSize = _subjects.data.length;
                          _offstage = true;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: subjectSize,
                            itemBuilder: (context, index) {
                              String s = _subjects.data[index]['subject'];
                              int id = _subjects.data[index]['id'];
                              return ListTile(
                                title: Text("$s"),
                                subtitle: Row(
                                  children: <Widget>[
                                    Text("${this._homeworkCompleted[id]}"),
                                  ],
                                ),
                                trailing: Icon(Icons.access_time),
                                onTap: () {
                                  _showTimePicker(id);
                                },
                                onLongPress: () {
                                  setState(() {
                                    _homeworkCompleted[id] = "完成时间";
                                    _homeworkStub.clearCompleteTime(id);
                                  });
                                },
                              );
                            },
                          );
                        } else {
                          _offstage = false;
                          return Text("加载中...");
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Tab(
            //   child: Text('开发中...'),
            // ),
            // Tab(
            //   child: Text('开发中...'),
            // ),
          ],
        ),
      ),
    );
  }
}
