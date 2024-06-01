class ReceiptDescriptionModel {
  final dynamic productid;
  final dynamic productname;
  final dynamic price;
  final dynamic quantity;
  final dynamic stocks;

  ReceiptDescriptionModel(
    this.productid,
    this.productname,
    this.price,
    this.quantity,
    this.stocks,
  );

  factory ReceiptDescriptionModel.fromJson(Map<String, dynamic> json) {
    return ReceiptDescriptionModel(
      json['productid'],
      json['productname'],
      json['price'],
      json['quantity'],
      json['stocks'],
    );
  }
}
