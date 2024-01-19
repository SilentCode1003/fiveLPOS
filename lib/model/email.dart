class EmailModel {
  final String emailaddress;
  final String branchname;
  final String tin;
  final String address;
  final String logo;

  EmailModel(
      this.emailaddress, this.branchname, this.tin, this.address, this.logo);

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      json['branchid'],
      json['branchname'],
      json['tin'],
      json['address'],
      json['logo'],
    );
  }
}
