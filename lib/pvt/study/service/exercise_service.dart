import 'package:date_format/date_format.dart';
import 'package:niuniu/pvt/study/entity/exercise.dart';
import 'package:niuniu/pvt/study/util/network_util.dart';

class ExerciseService {
  Future<Map<DateTime, List<Exercise>>> findByApprovalDate(
      DateTime begin, DateTime end) async {

    var exerciseJson = await NetworkUtil.getJson("/exercise_fetch", {
      "begin": formatDate(begin, [yyyy, "-", mm, "-", dd]),
      "end": formatDate(end, [yyyy, "-", mm, "-", dd]),
    });

    Map<DateTime, List<Exercise>> exerciseList = Map();

    exerciseJson.map((e) => Exercise.fromJson(e)).forEach((exercise) {
      var dt = exercise.approvalDate;
      if (!exerciseList.containsKey(dt)) {
        exerciseList[dt] = List();
      }
      exerciseList[dt].add(exercise);
    });

    return exerciseList;
  }
}
