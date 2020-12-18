import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/subject.dart';
import 'package:niuniu/pvt/study/util/network_util.dart';
import 'package:sprintf/sprintf.dart';

class Homework {
  final int id;
  final Subject subject;
  final DateTime publishDate;
  final DateTime beginTime;
  final DateTime completeTime;

  Homework(
      {this.id,
      this.subject,
      this.publishDate,
      this.beginTime,
      this.completeTime});

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'],
      subject: Subject.fromJson(json['subject']),
      publishDate: NetworkUtil.jsonNvl(json, "publishDate", DateTime.parse),
      beginTime: NetworkUtil.jsonNvl(json, "beginTime", DateTime.parse),
      completeTime: NetworkUtil.jsonNvl(json, "completeTime", DateTime.parse),
    );
  }

  String get timeLable {
    if (beginTime != null && completeTime != null) {
      return sprintf("%s - %s", [
        formatDate(beginTime, [hh, ":", nn, " ", am]),
        formatDate(completeTime, [hh, ":", nn, " ", am])
      ]);
    } else {
      return "时间";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "subjectId": subject.id,
      "publishDate": formatDate(publishDate, [yyyy, "-", mm, "-", dd]),
      "beginTime": formatDate(
          beginTime, [yyyy, "-", mm, "-", dd, " ", HH, ':', nn, ':', ss]),
      "completeTime": formatDate(
          completeTime, [yyyy, "-", mm, "-", dd, " ", HH, ':', nn, ':', ss]),
    };
  }

  @override
  String toString() {
    return sprintf(
        "Homework(id=%d, subject=%s, publishDate=%s, beginTime=%s, completeTime=%s)",
        [
          id != null ? id : -1,
          subject != null ? subject.toString() : " null ",
          publishDate != null
              ? formatDate(publishDate, [yyyy, "-", mm, "-", dd])
              : " null ",
          beginTime != null
              ? formatDate(beginTime, [HH, ':', nn, ':', ss])
              : " null ",
          completeTime != null
              ? formatDate(completeTime, [HH, ':', nn, ':', ss])
              : " null ",
        ]);
  }
}
