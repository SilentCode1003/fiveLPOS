import 'dart:convert';
import 'dart:io';

import 'package:fivelPOS/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class CategoryAPI {
  Future<Map<String, dynamic>> getCategory() async {
    Map<String, dynamic> api = {};
    Map<String, dynamic> userinfo = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
      userinfo = await Helper().readJsonToFile('user.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
      userinfo = await Helper().jsonToFileReadAndroid('user.json');
    }

    print(userinfo['APK']);
    final url = Uri.parse('${api['uri']}${Config.getCategoryAPI}');
    final response = await http.post(url, body: {
      'APK': userinfo['APK'],
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
