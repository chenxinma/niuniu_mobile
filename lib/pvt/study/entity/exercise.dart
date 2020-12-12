import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/subject.dart';

class Exercise {
  final int id;

  int newSubjectId;

  Subject subject;
  String grade;
  String title;
  DateTime approvalDate;

  Exercise({this.id, this.subject, this.approvalDate, this.grade, this.title, this.newSubjectId});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      subject: Subject.fromJson(json['subject']),
      approvalDate: DateTime.parse(json["approvalDate"]).toLocal(),
      grade: json['grade'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "subjectId": subject.id,
      "newSubjectId": newSubjectId,
      "approvalDate": formatDate(approvalDate, [yyyy, "-", mm, "-", dd]),
      "grade": grade,
      "title": title,
    };
  }
}
