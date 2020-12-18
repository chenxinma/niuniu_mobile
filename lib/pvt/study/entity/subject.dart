import 'package:sprintf/sprintf.dart';

class Subject {
  final int id;
  final String subject;

  Subject({this.id, this.subject});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      subject: json['subject'],
    );
  }

  @override
  String toString() {
    return sprintf("Subject(id=%d, subject=%s )", [id, subject]);
  }
}
