class POSModel {
  final dynamic posid;
  final dynamic posname;
  final dynamic serial;
  final dynamic min;
  final dynamic ptu;
  final dynamic status;
  final dynamic createdby;
  final dynamic createddate;

  POSModel(this.posid, this.posname, this.serial, this.min, this.ptu,
      this.status, this.createdby, this.createddate);

  factory POSModel.fromJson(Map<String, dynamic> json) {
    return POSModel(json['posid'], json['posname'], json['serial'], json['min'],
        json['ptu'], json['status'], json['createdby'], json['createddate']);
  }
}
