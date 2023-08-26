class BranchModel {
  final String branchid;
  final String branchname;
  final String tin;
  final String address;
  final String logo;

  BranchModel(
      this.branchid, this.branchname, this.tin, this.address, this.logo);

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      json['branchid'],
      json['branchname'],
      json['tin'],
      json['address'],
      json['logo'],
    );
  }
}
