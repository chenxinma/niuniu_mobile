import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/homework.dart';
import 'package:niuniu/pvt/study/entity/subject.dart';
import 'package:niuniu/pvt/study/util/network_util.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
// ignore: implementation_imports
import 'package:time_range_picker/src/utils.dart';

class HomeworkService {
  Future<Map<int, Homework>> loadHomework(DateTime publishDate) async {
    Map<int, Homework> homeworkList = Map();
    List<dynamic> homeworkJson = await NetworkUtil.getJson("/homework", {"publishDate":
        formatDate(publishDate, [yyyy, "-", mm, "-", dd])});

    homeworkJson.map((e) => Homework.fromJson(e)).forEach((homework) {
      homeworkList[homework.subject.id] = homework;
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

  String formatTimeRange(Homework homework) {
    return sprintf("%s - %s", [
      formatDate(homework.beginTime, [hh, ":", nn, " ", am]),
      formatDate(homework.completeTime, [hh, ":", nn, " ", am])
    ]);
  }

  Homework create({DateTime publishDate, int subjectId, TimeRange workTimeRange, int homeworkId}) {
    Homework h = Homework(
      publishDate: publishDate,
      subject: Subject(id: subjectId),
      beginTime: DateTime(publishDate.year, publishDate.month, publishDate.day,
          workTimeRange.startTime.hour, workTimeRange.startTime.minute),
      completeTime: DateTime(
          publishDate.year, publishDate.month, publishDate.day,
          workTimeRange.endTime.hour, workTimeRange.endTime.minute),
    );
    return h;
  }
}