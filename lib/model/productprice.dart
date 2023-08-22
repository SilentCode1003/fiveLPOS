class ProductPriceModel {
  final String productid;
  final String description;
  final String barcode;
  final String productimage;
  final String price;
  final String category;

  ProductPriceModel(this.productid, this.description, this.barcode,
      this.productimage, this.price, this.category);

  factory ProductPriceModel.fromJson(Map<String, dynamic> json) {
    return ProductPriceModel(
      json['productid'],
      json['description'],
      json['barcode'],
      json['productimage'],
      json['price'],
      json['category'],
    );
  }
}
