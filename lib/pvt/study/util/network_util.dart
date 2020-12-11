import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:niuniu/pvt/study/config/app_config.dart';

class NetworkUtil {
  static String _baseUrl = AppConfig.base_url;

  static String _parseUrl([Map data]) {
    String query = "";
    if (data != null) {
      query = "?";
      String mark = "";
      data.forEach((key, value) {
        query += mark + key + "=" + value;
        mark = "&";
      });
    }
    return query;
  }

  static Future<http.Response> delete(String path, [Map data]) {
    return http.delete(_baseUrl + path + _parseUrl(data));
  }

  static Future<http.Response> get(String path, [Map data]) {
    return http.get(_baseUrl + path + _parseUrl(data));
  }

  static Future<http.Response> post(String path, dynamic data) async {
    var body = utf8.encode(json.encode(data));
    var addPost = await http.post(_baseUrl + path,
        headers: {"content-type": "application/json"}, body: body);

    return addPost;
  }

  static dynamic getJson(String path, [Map data]) async {
    http.Response resp = await get(path, data);
    return fetchResp(resp);
  }

  static dynamic fetchResp(http.Response resp) {
    if (resp.statusCode != 200) {
      throw Exception(resp.body);
    }
    return jsonDecode(Utf8Decoder().convert(resp.bodyBytes));
  }

  static dynamic jsonNvl(Map json, String key, [Function convert]) {
    var data;
    if (convert != null) {
      data = json.containsKey(key) && json[key] != null
          ? convert(json[key])
          : null;
    } else {
      data = json.containsKey(key) && json[key] != null ? json[key] : null;
    }
    return data;
  }

}
