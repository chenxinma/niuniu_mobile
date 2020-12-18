import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/homework.dart';
import 'package:niuniu/pvt/study/entity/subject.dart';
import 'package:niuniu/pvt/study/util/network_util.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
// ignore: implementation_imports
import 'package:time_range_picker/src/utils.dart';

class HomeworkService {
  Future<List<Homework>> loadHomework(DateTime publishDate) async {
    List<dynamic> homeworkJson = await NetworkUtil.getJson("/homework", {
      "publishDate": formatDate(publishDate, [yyyy, "-", mm, "-", dd])
    });

    return homeworkJson.map((e) => Homework.fromJson(e)).toList();
  }

  Future<Map<DateTime, List<Homework>>> loadHomework2(
      DateTime begin, DateTime end) async {
    List<dynamic> homeworkJson = await NetworkUtil.getJson("/homework_fetch", {
      "begin": formatDate(begin, [yyyy, "-", mm, "-", dd]),
      "end": formatDate(end, [yyyy, "-", mm, "-", dd]),
    });

    Map<DateTime, List<Homework>> homeworkList = Map();

    homeworkJson.map((e) => Homework.fromJson(e)).forEach((homework) {
      DateTime dt = homework.publishDate;
      if (!homeworkList.containsKey(dt)) {
        homeworkList[dt] = List();
      }
      homeworkList[dt].add(homework);
    });

    return homeworkList;
  }

  Future<int> saveOnTimePicker(Homework homework) async {
    http.Response resp = await NetworkUtil.post("/homework", homework.toMap());
    return int.parse(resp.body);
  }

  void clearTime(int id) async {
    await NetworkUtil.delete("/homework/$id/time_range");
  }

  Homework create(
      {DateTime publishDate,
      int subjectId,
      TimeRange workTimeRange,
      int homeworkId}) {
    Homework h = Homework(
      publishDate: publishDate,
      subject: Subject(id: subjectId),
      beginTime: DateTime(publishDate.year, publishDate.month, publishDate.day,
          workTimeRange.startTime.hour, workTimeRange.startTime.minute),
      completeTime: DateTime(
          publishDate.year,
          publishDate.month,
          publishDate.day,
          workTimeRange.endTime.hour,
          workTimeRange.endTime.minute),
      id: homeworkId,
    );
    return h;
  }

  Future<int> delete(int id) async {
    http.Response resp =
        await NetworkUtil.delete(sprintf("/homework/%d", [id]));
    return int.parse(resp.body);
  }

  List<Homework> fill(
      List<Homework> selectedHomework, List subjects, DateTime selectedDate) {
    List<Homework> results = [];
    results.addAll(selectedHomework);
    subjects.forEach((e) {
      Subject subject = e as Subject;
      int idx = selectedHomework.indexWhere((e) => e.subject.id == subject.id);
      if (idx < 0) {
        results.add(Homework(subject: subject, publishDate: selectedDate));
      }
    });

    return results;
  }
}
