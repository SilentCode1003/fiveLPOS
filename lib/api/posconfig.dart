import 'dart:convert';
import 'dart:io';

import 'package:fiveLPOS/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class PosConfigAPI {
  Future<Map<String, dynamic>> posconfig(
    String posid,
  ) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().JsonToFileRead('server.json');
    }

    final url = Uri.parse('${api['uri']}${Config.getPosConfig}');
    final response = await http.post(url, body: {
      'posid': posid,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final result = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': result};

    return data;
  }
}
