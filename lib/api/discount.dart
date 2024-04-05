import 'dart:convert';
import 'dart:io';

import 'package:fiveLPOS/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class DiscountAPI {
  Future<Map<String, dynamic>> getDiscountRate(String type) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().JsonToFileRead('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.discountRateAPI}');
    final response = await http.post(url, body: {'name': type});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> getDiscount() async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().JsonToFileRead('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.getDiscountAPI}');
    final response = await http.get(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> salesDiscount(String detailid, String discountid,
      List<Map<String, dynamic>> customerinfo, String amount) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().JsonToFileRead('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.salesDiscountAPI}');
    final response = await http.post(url, body: {
      'detailid': detailid,
      'discountid': discountid,
      'customerinfo': customerinfo,
      'amount': amount
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
