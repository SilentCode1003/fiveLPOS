class CustomerModel {
  final dynamic id;
  final dynamic fullname;

  CustomerModel(this.id, this.fullname);

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      json['id'],
      json['fullname'],
    );
  }

  static List<CustomerModel> fromJsonList(json) {
    return json
        .map<CustomerModel>((item) => CustomerModel.fromJson(item))
        .toList();
  }
}
