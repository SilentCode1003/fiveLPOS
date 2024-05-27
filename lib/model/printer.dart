import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class PrinterModel {
  final String printername;
  final String printerip;
  final String papersize;
  final bool isenable;

  PrinterModel(this.printername, this.printerip, this.papersize, this.isenable);

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(json['printername'], json['printerip'],
        json['papersize'], json['isenable']);
  }
}
