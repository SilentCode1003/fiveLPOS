class ServicePackageModel {
  final int id;
  final String name;
  final String details;
  final int price;
  final String status;
  final String createdby;
  final String createddate;

  ServicePackageModel(this.id, this.name, this.details, this.price, this.status,
      this.createdby, this.createddate);

  factory ServicePackageModel.fromJson(Map<String, dynamic> json) {
    return ServicePackageModel(json['id'], json['name'], json['details'],
        json['price'], json['status'], json['createdby'], json['createddate']);
  }
}
