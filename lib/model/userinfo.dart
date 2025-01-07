class UserInfoModel {
  final String employeeid;
  final String fullname;
  final int position;
  final String contactinfo;
  final String datehired;
  final int usercode;
  final int accesstype;
  final String status;
  final String APK;

  UserInfoModel(this.employeeid, this.fullname, this.position, this.contactinfo,
      this.datehired, this.usercode, this.accesstype, this.status, this.APK);

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      json['employeeid'],
      json['fullname'],
      json['position'],
      json['contactinfo'],
      json['datehired'],
      json['usercode'],
      json['accesstype'],
      json['status'],
      json['APK'],
    );
  }
}
