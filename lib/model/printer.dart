import 'package:esc_pos_utils/esc_pos_utils.dart';

class PrinterModel {
  final String printername;
  final String printerip;
  final String papersize;

  PrinterModel(this.printername, this.printerip, this.papersize);

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
        json['printername'], json['printerip'], json['papersize']);
  }
}
