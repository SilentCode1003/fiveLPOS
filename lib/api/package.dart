import 'dart:convert';
import 'dart:io';

import '/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class PackageAPI {
  Future<Map<String, dynamic>> getPackage(String stat) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.packageAPI}');
    final response = await http.post(url, body: {'status': stat});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    final jsonData = json.encode(results);

    // File file = File('assets/branch.json');
    // if (file.existsSync()) {
    // } else {
    //   await file.writeAsString(jsonData);
    // }

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
