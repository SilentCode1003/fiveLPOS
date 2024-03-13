class ServiceModel {
  final int id;
  final String name;
  final int price;
  final String status;
  final String createdby;
  final String createddate;

  ServiceModel(this.id, this.name, this.price, this.status, this.createdby,
      this.createddate);

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(json['id'], json['name'], json['price'], json['status'],
        json['createdby'], json['createddate']);
  }
}
