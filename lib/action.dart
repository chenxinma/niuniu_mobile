import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';

BaseOptions options = new BaseOptions(
  baseUrl: "http://192.168.1.30:4567/api",
  connectTimeout: 5000,
  receiveTimeout: 3000,
);

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}

class Subject {
  Dio _dio;
  List _cache;

  Subject([Dio dio]) {
    if (dio == null) {
      this._dio = Dio(options);
      (_dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    } else {
      this._dio = dio;
    }
  }

  Future<List> get subjects async {
    Response response = await _dio.get("/subject");
    return response.data;
  }

  List get subjectsCache {
    return _cache;
  }

  void cache(List data) {
    _cache = [];
    data.forEach((element) {
      _cache.add({"id": element["id"], "subject": element["subject"]});
    });
  }
}

class Homework {
  Map<int, int> _savedHomeworkIds = Map();
  Dio _dio;
  DateTime _publishDate;

  Homework([Dio dio]) {
    if (dio == null) {
      this._dio = Dio(options);
      (_dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    } else {
      this._dio = dio;
    }
  }

  Future<Response> loadHomeworks(DateTime publishDate) async {
    this._publishDate = publishDate;
    Response<List> response = await _dio.get("/homework?publishDate=" +
        formatDate(publishDate, [yyyy, "-", mm, "-", dd]));
    _savedHomeworkIds.clear();
    response.data.forEach((element) {
      _savedHomeworkIds[element['subject']['id']] = element['id'];
    });
    return response;
  }

  Future<Response> saveOnTimePicker(int subjectId, TimeRange range) async {
    var cc1 = DateTime(_publishDate.year, _publishDate.month, _publishDate.day,
        range.startTime.hour, range.startTime.minute);
    var cc2 = DateTime(_publishDate.year, _publishDate.month, _publishDate.day,
        range.endTime.hour, range.endTime.minute);
    var homework = {
      "subjectId": subjectId,
      "publishDate": formatDate(_publishDate, [yyyy, "-", mm, "-", dd]),
      "beginTime":
          formatDate(cc1, [yyyy, "-", mm, "-", dd, " ", HH, ':', nn, ':', ss]),
      "completeTime":
          formatDate(cc2, [yyyy, "-", mm, "-", dd, " ", HH, ':', nn, ':', ss]),
    };
    if (_savedHomeworkIds.containsKey(subjectId)) {
      homework['id'] = _savedHomeworkIds[subjectId];
    }
    Response<int> response = await _dio.post(
      "/homework",
      data: homework,
    );
    return response;
  }

  void clearCompleteTime(int subjectId) async {
    var id = _savedHomeworkIds[subjectId];
    Response response = await _dio.delete("/homework/$id/complete_time");
    if (response.statusCode != 200) {
      print("error on clearCompleteTime");
    }
  }
}
