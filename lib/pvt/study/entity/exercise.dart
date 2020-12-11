import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/subject.dart';
import 'package:niuniu/pvt/study/util/network_util.dart';

class Exercise {
  final int id;

  Subject subject;
  String grade;
  String title;
  DateTime approvalDate;

  Exercise({this.id, this.subject, this.approvalDate, this.grade, this.title});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      subject: Subject.fromJson(json['subject']),
      approvalDate: NetworkUtil.jsonNvl(json, "approvalDate", DateTime.parse),
      grade: json['grade'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "subjectId": subject.id,
      "approvalDate": formatDate(approvalDate, [yyyy, "-", mm, "-", dd]),
      "grade": grade,
      "title": title,
    };
  }
}
