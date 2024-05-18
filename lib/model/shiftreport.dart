class ShiftReportModel {
  final dynamic date;
  final dynamic pos;
  final dynamic shift;
  final dynamic cashier;
  final dynamic floating;
  final dynamic cashfloat;
  final dynamic salesbeginning;
  final dynamic salesending;
  final dynamic totalsales;
  final dynamic receiptbeginning;
  final dynamic receiptending;
  final dynamic status;
  final dynamic approvedby;
  final dynamic approveddate;

  ShiftReportModel(
      this.date,
      this.pos,
      this.shift,
      this.cashier,
      this.floating,
      this.cashfloat,
      this.salesbeginning,
      this.salesending,
      this.totalsales,
      this.receiptbeginning,
      this.receiptending,
      this.status,
      this.approvedby,
      this.approveddate);

  factory ShiftReportModel.fromJson(Map<String, dynamic> json) {
    return ShiftReportModel(
        json['date'],
        json['pos'],
        json['shift'],
        json['cashier'],
        json['floating'],
        json['cashfloat'],
        json['salesbeginning'],
        json['salesending'],
        json['totalsales'],
        json['receiptbeginning'],
        json['receiptending'],
        json['status'],
        json['approvedby'],
        json['approveddate']);
  }
}

class SoldItemModel {
  final dynamic item;
  final dynamic price;
  final dynamic quantity;
  final dynamic total;

  SoldItemModel(
    this.item,
    this.price,
    this.quantity,
    this.total,
  );

  factory SoldItemModel.fromJson(Map<String, dynamic> json) {
    return SoldItemModel(
      json['item'],
      json['price'],
      json['quantity'],
      json['total'],
    );
  }
}

class SummaryPaymentModel {
  final dynamic paymenttype;
  final dynamic total;

  SummaryPaymentModel(
    this.paymenttype,
    this.total,
  );

  factory SummaryPaymentModel.fromJson(Map<String, dynamic> json) {
    return SummaryPaymentModel(
      json['paymenttype'],
      json['total'],
    );
  }
}

class StaffSalesModel {
  final dynamic salesstaff;
  final dynamic total;

  StaffSalesModel(
    this.salesstaff,
    this.total,
  );

  factory StaffSalesModel.fromJson(Map<String, dynamic> json) {
    return StaffSalesModel(
      json['salesstaff'],
      json['total'],
    );
  }
}

class ShiftReceiptModel {
  final dynamic date;
  final dynamic pos;
  final dynamic shift;
  final dynamic cashier;
  final dynamic salesbeginning;
  final dynamic salesending;
  final dynamic totalsales;
  final dynamic receiptbeginning;
  final dynamic receiptending;
  final List<SoldItemModel> items;
  final List<SummaryPaymentModel> summarypayments;
  final List<StaffSalesModel> salesstaff;

  ShiftReceiptModel(
      this.date,
      this.pos,
      this.shift,
      this.cashier,
      this.salesbeginning,
      this.salesending,
      this.totalsales,
      this.receiptbeginning,
      this.receiptending,
      this.items,
      this.summarypayments,
      this.salesstaff);

  factory ShiftReceiptModel.fromJson(Map<String, dynamic> json) {
    return ShiftReceiptModel(
      json['date'],
      json['pos'],
      json['shift'],
      json['cashier'],
      json['salesbeginning'],
      json['salesending'],
      json['totalsales'],
      json['receiptbeginning'],
      json['receiptending'],
      json['items'],
      json['summarypayments'],
      json['salesstaff'],
    );
  }
}
