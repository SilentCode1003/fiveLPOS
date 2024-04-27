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
