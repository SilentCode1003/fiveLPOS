import 'dart:convert';
import 'dart:io';

import '../model/response.dart';
import 'package:fivelPOS/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class SalesDetails {
  Future<Map<String, dynamic>> getdetailid(String posid) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.getdetailidAPI}');
    final response = await http.post(url, body: {'posid': posid});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> getdetails(String detailid) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.getdetailsAPI}');
    final response = await http.post(url, body: {'detailid': detailid});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> refund(
      String detailid, String reason, String cashier) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.refundAPI}');
    final response = await http.post(url, body: {
      'detailid': detailid,
      'reason': reason,
      'cashier': cashier,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<ResponseModel> getreceipts(
      String datefrom, String dateto, String posid) async {
    Map<String, dynamic> api = {};
    if (Platform.isWindows) {
      api = await Helper().readJsonToFile('server.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
    }
    final url = Uri.parse('${api['uri']}${Config.getreceiptsAPI}');
    final response = await http.post(url,
        body: {'datefrom': datefrom, 'dateto': dateto, 'posid': posid});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    ResponseModel data =
        ResponseModel.fromJson({'msg': msg, 'status': status, 'data': results});

    return data;
  }
}
