import 'dart:convert';

import 'package:fivelPOS/model/discountdetail.dart';
import 'package:fivelPOS/model/items.dart';

class RefundModel {
  final dynamic detaildid;
  final dynamic reason;
  final dynamic cashier;

  RefundModel(this.detaildid, this.reason, this.cashier);

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      json['detailid'],
      json['reason'],
      json['cashier'],
    );
  }
}
