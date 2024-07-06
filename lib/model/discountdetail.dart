import 'dart:convert';

import 'package:fivelPOS/model/customert.dart';

class DiscountDetailModel {
  final dynamic detailid;
  final dynamic discountid;
  final List<CustomerModel> customerinfo;
  final dynamic amount;

  DiscountDetailModel(
      this.detailid, this.discountid, this.customerinfo, this.amount);

  factory DiscountDetailModel.fromJson(Map<String, dynamic> json) {
    return DiscountDetailModel(json['detailid'], json['discountid'],
        CustomerModel.fromJsonList(json['customerinfo']), json['amount']);
  }

  static List<DiscountDetailModel> fromJsonList(json) {
    return json
        .map<DiscountDetailModel>((item) => DiscountDetailModel.fromJson(item))
        .toList();
  }
}
