import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class CategoryAPI {
  Future<Map<String, dynamic>> getCategory() async {
    final url = Uri.parse('${Config.apiUrl}${Config.getCategoryAPI}');
    final response = await http.get(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
