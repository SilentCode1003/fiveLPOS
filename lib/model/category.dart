class CategoryModel {
  final int categorycode;
  final String categoryname;
  final String status;
  final String createdby;
  final String createddate;

  CategoryModel(this.categorycode, this.categoryname, this.status,
      this.createdby, this.createddate);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      json['categorycode'],
      json['categoryname'],
      json['status'],
      json['createdby'],
      json['createddate'],
    );
  }
}
