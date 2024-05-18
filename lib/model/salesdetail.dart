class SalesDetailModel {
  final dynamic detailid;
  final dynamic date;
  final dynamic posid;
  final dynamic shift;
  final dynamic paymenttype;
  final dynamic cashfloat;
  final dynamic salesbeginning;
  final dynamic salesending;
  final dynamic totalsales;
  final dynamic receiptbeginning;
  final dynamic receiptending;

  SalesDetailModel(
    this.detailid,
    this.date,
    this.posid,
    this.shift,
    this.paymenttype,
    this.cashfloat,
    this.salesbeginning,
    this.salesending,
    this.totalsales,
    this.receiptbeginning,
    this.receiptending,
  );

  factory SalesDetailModel.fromJson(Map<String, dynamic> json) {
    return SalesDetailModel(
      json['detailid'],
      json['date'],
      json['posid'],
      json['shift'],
      json['paymenttype'],
      json['cashfloat'],
      json['salesbeginning'],
      json['salesending'],
      json['totalsales'],
      json['receiptbeginning'],
      json['receiptending'],
    );
  }
}
