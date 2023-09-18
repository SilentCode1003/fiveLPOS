import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class Login {
  Future<Map<String, dynamic>> authenticate(
    String username,
    String password,
  ) async {
    final url = Uri.parse('${Config.apiUrl}${Config.authenticationLoginAPI}');
    final response = await http.post(url, body: {
      'username': username,
      'password': password,
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
