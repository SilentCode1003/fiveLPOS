class PromoModel {
  final int promoid;
  final String name;
  final String description;
  final String condition;
  final String startdate;
  final String enddate;
  final String status;
  final String createdby;
  final String createddate;

  PromoModel(
    this.promoid,
    this.name,
    this.description,
    this.condition,
    this.startdate,
    this.enddate,
    this.status,
    this.createdby,
    this.createddate,
  );

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      json['promoid'],
      json['name'],
      json['description'],
      json['condition'],
      json['startdate'],
      json['enddate'],
      json['status'],
      json['createdby'],
      json['createddate'],
    );
  }
}
