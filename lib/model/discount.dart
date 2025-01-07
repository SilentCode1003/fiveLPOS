class DiscountModel {
  final int discountid;
  final String discountname;
  final String description;
  final rate;
  final String status;
  final String createdby;
  final String createddate;

  DiscountModel(this.discountid, this.discountname, this.description, this.rate,
      this.status, this.createdby, this.createddate);

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      json['discountid'],
      json['discountname'],
      json['description'],
      json['rate'],
      json['status'],
      json['createdby'],
      json['createddate'],
    );
  }
}
