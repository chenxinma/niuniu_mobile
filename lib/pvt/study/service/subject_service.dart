import 'package:niuniu/pvt/study/entity/subject.dart';
import 'package:niuniu/pvt/study/util/network_util.dart';

class SubjectService {
  Future<List> get subjects async {
    List<dynamic> subjectsJson = await NetworkUtil.getJson("/subject");
    return subjectsJson.map((e) => Subject.fromJson(e)).toList();
  }
}