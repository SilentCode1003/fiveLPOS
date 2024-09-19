import 'dart:convert';

import 'package:fivelPOS/model/discountdetail.dart';
import 'package:fivelPOS/model/items.dart';

class SplitSalesModel {
  final dynamic detaildid;
  final dynamic date;
  final dynamic posid;
  final dynamic shift;
  final List<ItemsModel> items;
  final dynamic staff;
  final dynamic firstpayment;
  final dynamic secondpayment;
  final dynamic firstpaymenttype;
  final dynamic secondpaymenttype;
  final dynamic branchid;
  final dynamic firstpatmentreference;
  final dynamic secondpaymentreference;
  final List<DiscountDetailModel> discountdetails;
  final dynamic total;

  SplitSalesModel(
      this.detaildid,
      this.date,
      this.posid,
      this.shift,
      this.items,
      this.staff,
      this.firstpayment,
      this.secondpayment,
      this.firstpaymenttype,
      this.secondpaymenttype,
      this.branchid,
      this.firstpatmentreference,
      this.secondpaymentreference,
      this.discountdetails,
      this.total);

  factory SplitSalesModel.fromJson(Map<String, dynamic> json) {
    return SplitSalesModel(
      json['detailid'],
      json['date'],
      json['posid'],
      json['shift'],
      ItemsModel.fromJsonList(jsonDecode(json['items'])),
      json['staff'],
      json['firstpayment'],
      json['secondpayment'],
      json['firstpaymenttype'],
      json['secondpaymenttype'],
      json['branchid'],
      json['firstpatmentreference'],
      json['secondpaymentreference'],
      DiscountDetailModel.fromJsonList(jsonDecode(json['discountdetail'])),
      json['total'],
    );
  }
}
