class AddonModel {
  final int id;
  final String name;
  final String type;
  final int price;
  final String status;
  final String createdby;
  final String createddate;

  AddonModel(this.id, this.name, this.type, this.price, this.status,
      this.createdby, this.createddate);

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(json['id'], json['name'], json['type'], json['price'],
        json['status'], json['createdby'], json['createddate']);
  }
}
