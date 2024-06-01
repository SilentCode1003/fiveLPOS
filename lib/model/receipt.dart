class ReceiptModel {
  final String? detailid;
  final String? date;
  final String? posid;
  final String? shift;
  final String? paymenttype;
  final String? description;
  final String? total;
  final String? cashier;
  final String? branch;
  final String? status;
  final String? tenderpaymenttype;
  final int? tenderamount;
  final String? epaymenttype;
  final String? referenceid;

  ReceiptModel(
      this.detailid,
      this.date,
      this.posid,
      this.shift,
      this.paymenttype,
      this.description,
      this.total,
      this.cashier,
      this.branch,
      this.status,
      this.tenderpaymenttype,
      this.tenderamount,
      this.epaymenttype,
      this.referenceid);

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      json['detail_id'],
      json['date'],
      json['pos_id'],
      json['shift'],
      json['payment_type'],
      json['description'],
      json['total'],
      json['cashier'],
      json['branch'],
      json['status'],
      json['tenderpaymenttype'],
      json['tenderamount'],
      json['epaymenttype'],
      json['referenceid'],
    );
  }
}
