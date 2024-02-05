class EmployeesModel {
  final String employeeid;
  final String fullname;
  final String position;
  final String datehired;
  final String status;
  final String createdby;
  final String createddate;

  EmployeesModel(this.employeeid, this.fullname, this.position, this.datehired,
      this.status, this.createdby, this.createddate);

  factory EmployeesModel.fromJson(Map<String, dynamic> json) {
    return EmployeesModel(
      json['employeeid'],
      json['fullname'],
      json['position'],
      json['datehired'],
      json['status'],
      json['createdby'],
      json['createddate'],
    );
  }
}
