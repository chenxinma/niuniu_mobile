import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/exercise.dart';
import 'package:niuniu/pvt/study/util/network_util.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';

class ExerciseService {
  Future<Map<DateTime, List<Exercise>>> findByApprovalDateRange(
      DateTime begin, DateTime end) async {
    var exerciseJson = await NetworkUtil.getJson("/exercise_fetch", {
      "begin": formatDate(begin, [yyyy, "-", mm, "-", dd]),
      "end": formatDate(end, [yyyy, "-", mm, "-", dd]),
    });

    Map<DateTime, List<Exercise>> exerciseList = Map();

    exerciseJson.map((e) => Exercise.fromJson(e)).forEach((exercise) {
      DateTime dt = exercise.approvalDate;
      if (!exerciseList.containsKey(dt)) {
        exerciseList[dt] = List();
      }
      exerciseList[dt].add(exercise);
    });

    return exerciseList;
  }

  Future<List<Exercise>> findByApprovalDate(DateTime approvalDate) async {
    List exerciseJson = await NetworkUtil.getJson("/exercise", {
      "approvalDate": formatDate(approvalDate, [yyyy, "-", mm, "-", dd]),
    });

    return exerciseJson.map((e) => Exercise.fromJson(e)).toList();
  }

  Future<int> save(Exercise exercise) async {
    http.Response resp = await NetworkUtil.post("/exercise", exercise.toMap());
    return int.parse(resp.body);
  }

  Future<int> delete(int id) async {
    http.Response resp = await NetworkUtil.delete(sprintf("/exercise/%d", [id]));
    return int.parse(resp.body);
  }
}
