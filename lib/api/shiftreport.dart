import 'dart:convert';
import 'dart:io';

import 'package:fivelPOS/model/response.dart';

import 'package:fivelPOS/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class ShiftReportAPI {
  Future<Map<String, dynamic>> getShiftReport(
      String date, String posid, String shift) async {
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
    final url = Uri.parse('${api['uri']}${Config.shiftReportAPI}');
    final response = await http.post(url, body: {
      'date': date,
      'posid': posid,
      'shift': shift,
      'APK': userinfo['APK'],
    });

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

  Future<Map<String, dynamic>> getShiftItemSold(
      String beginingreceipt, String endingreceipt) async {
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
    final url = Uri.parse('${api['uri']}${Config.shiftItenSoldAPI}');
    final response = await http.post(url, body: {
      'beginingreceipt': beginingreceipt,
      'endingreceipt': endingreceipt,
      'APK': userinfo['APK'],
    });

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

  Future<Map<String, dynamic>> getShiftSummaryPayment(
      String beginingreceipt, String endingreceipt) async {
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
    final url = Uri.parse('${api['uri']}${Config.shiftSummaryPaymentAPI}');
    final response = await http.post(url, body: {
      'beginingreceipt': beginingreceipt,
      'endingreceipt': endingreceipt,
      'APK': userinfo['APK'],
    });

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

  Future<Map<String, dynamic>> getShiftStaffSales(
      String beginingreceipt, String endingreceipt) async {
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
    final url = Uri.parse('${api['uri']}${Config.shiftStaffSalesAPI}');
    final response = await http.post(url, body: {
      'beginingreceipt': beginingreceipt,
      'endingreceipt': endingreceipt,
      'APK': userinfo['APK'],
    });

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

  Future<ResponseModel> getShiftReports(String date, String posid) async {
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
    final url = Uri.parse('${api['uri']}${Config.getreportAPI}');
    final response = await http.post(url, body: {'date': date, 'posid': posid, 'APK': userinfo['APK']});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    ResponseModel data =
        ResponseModel.fromJson({'msg': msg, 'status': status, 'data': results});

    return data;
  }
}
