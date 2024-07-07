class EmailModel {
  final String emailaddress;
  final String emailpassword;
  final String emailserver;

  EmailModel(this.emailaddress, this.emailpassword, this.emailserver);

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
        json['emailaddress'], json['emailpassword'], json['emailserver']);
  }
}
