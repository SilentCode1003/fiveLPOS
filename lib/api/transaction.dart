import 'dart:convert';
import 'dart:io';

import 'package:fivelPOS/repository/customerhelper.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class POSTransaction {
  Future<Map<String, dynamic>> sending(
      String detailid,
      String date,
      String posid,
      String shift,
      String paymenttype,
      String referenceid,
      String paymentname,
      String items,
      String total,
      String cashier,
      String cash,
      String ecash,
      String branch,
      String discountdetail) async {
    Map<String, dynamic> api = {};
    Map<String, dynamic> userinfo = {};
    if (Platform.isWindows) {
      // api = await helper.readJsonToFile('server.json');

      api = await Helper().readJsonToFile('server.json');
      userinfo = await Helper().readJsonToFile('user.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
      userinfo = await Helper().jsonToFileReadAndroid('user.json');
    }
    final url = Uri.parse('${api['uri']}${Config.salesDetailAPI}');
    final response = await http.post(url, body: {
      'detailid': detailid,
      'date': date,
      'posid': posid,
      'shift': shift,
      'paymenttype': paymenttype,
      'description': items,
      'total': total,
      'cashier': cashier,
      'paymentname': paymentname,
      'referenceid': referenceid,
      'cash': cash,
      'ecash': ecash,
      'branch': branch,
      'discountdetail': discountdetail,
      'APK': userinfo['APK'],
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status};

    return data;
  }

  Future<Map<String, dynamic>> splitpayment(
      String detailid,
      String date,
      String posid,
      String shift,
      String items,
      String staff,
      String firstpayment,
      String secondpayment,
      String firstpaymenttype,
      String secondpaymenttype,
      String branchid,
      String firstpatmentreference,
      String secondpaymentreference,
      String discountdetails,
      String total) async {
    Map<String, dynamic> api = {};
    Map<String, dynamic> userinfo = {};
    if (Platform.isWindows) {
      // api = await helper.readJsonToFile('server.json');

      api = await Helper().readJsonToFile('server.json');
      userinfo = await Helper().readJsonToFile('user.json');
    }

    if (Platform.isAndroid) {
      api = await Helper().jsonToFileReadAndroid('server.json');
      userinfo = await Helper().jsonToFileReadAndroid('user.json');
    }
    final url = Uri.parse('${api['uri']}${Config.splitpaymentAPI}');
    final response = await http.post(url, body: {
      'detailid': detailid,
      'date': date,
      'posid': posid,
      'shift': shift,
      'items': items,
      'staff': staff,
      'firstpayment': firstpayment,
      'secondpayment': secondpayment,
      'firstpaymenttype': firstpaymenttype,
      'secondpaymenttype': secondpaymenttype,
      'branchid': branchid,
      'firstpatmentreference': firstpatmentreference,
      'secondpaymentreference': secondpaymentreference,
      'discountdetails': discountdetails,
      'total': total,
      'APK': userinfo['APK'],
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status};

    return data;
  }
}
