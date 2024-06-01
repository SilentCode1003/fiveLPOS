class ResponseModel {
  final dynamic message;
  final dynamic status;
  final dynamic data;

  ResponseModel(this.message, this.status, this.data);

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      json['message'],
      json['status'],
      json['data'],
    );
  }
}
