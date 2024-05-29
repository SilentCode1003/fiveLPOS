import 'dart:convert';
import 'dart:io';

import '/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class ProductPrice {
  Future<Map<String, dynamic>> getcategoryitems(
      String category, String branchid) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().JsonToFileRead('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.getcategoryAPI}');
    final response = await http.post(url, body: {
      'category': category,
      'branchid': branchid,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = json.encode(responseData['data']);

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> getitemserial(
      String barcode, String branchid) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().JsonToFileRead('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.getpriceAPI}');
    final response =
        await http.post(url, body: {'barcode': barcode, 'branchid': branchid});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = json.encode(responseData['data']);

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
