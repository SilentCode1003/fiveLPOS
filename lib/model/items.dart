class ItemsModel {
  final dynamic id;
  final dynamic name;
  final dynamic price;
  final dynamic quantity;
  final dynamic stocks;

  ItemsModel(this.id, this.name, this.price, this.quantity, this.stocks);

  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    return ItemsModel(
      json['id'],
      json['name'],
      json['price'],
      json['quantity'],
      json['stocks'],
    );
  }

  static List<ItemsModel> fromJsonList(json) {
    return json.map<ItemsModel>((item) => ItemsModel.fromJson(item)).toList();
  }
}
