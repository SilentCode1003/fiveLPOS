import 'dart:convert';

import 'package:fivelPOS/model/discountdetail.dart';
import 'package:fivelPOS/model/items.dart';

class SalesModel {
  final dynamic detaildid;
  final dynamic date;
  final dynamic posid;
  final dynamic shift;
  final dynamic paymenttype;
  final dynamic referenceid;
  final dynamic paymentname;
  final List<ItemsModel> items;
  final dynamic total;
  final dynamic cashier;
  final dynamic cash;
  final dynamic ecash;
  final dynamic branch;
  final List<DiscountDetailModel> discountdetail;
  final dynamic issync;

  SalesModel(
    this.detaildid,
    this.date,
    this.posid,
    this.shift,
    this.paymenttype,
    this.referenceid,
    this.paymentname,
    this.items,
    this.total,
    this.cashier,
    this.cash,
    this.ecash,
    this.branch,
    this.discountdetail,
    this.issync,
  );

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      json['detailid'],
      json['date'],
      json['posid'],
      json['shift'],
      json['paymenttype'],
      json['referenceid'],
      json['paymentname'],
      ItemsModel.fromJsonList(jsonDecode(json['items'])),
      json['total'],
      json['cashier'],
      json['cash'],
      json['ecash'],
      json['branch'],
      DiscountDetailModel.fromJsonList(jsonDecode(json['discountdetail'])),
      json['issync'],
    );
  }
}
