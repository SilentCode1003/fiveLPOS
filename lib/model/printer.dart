
class PrinterModel {
  final String printername;
  final String printerip;
  final String productionprinterip;
  final String papersize;
  final bool isenable;

  PrinterModel(this.printername, this.printerip, this.productionprinterip,
      this.papersize, this.isenable);

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(json['printername'], json['printerip'],
        json['productionprinterip'], json['papersize'], json['isenable']);
  }
}
