import 'dart:io';

import '/repository/customerhelper.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class OrderSlip {
  List<Map<String, dynamic>> items;
  String date;
  String ornumber;
  OrderSlip(this.items, this.date, this.ornumber);

  Future<List<int>> orderSlipReceipt(PaperSize paper, CapabilityProfile profile,
      List<Map<String, dynamic>> items) async {
    List<int> bytes = [];
    final Generator ticket = Generator(paper, profile);

    bytes += ticket.text('ORDER SLIP',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);
    bytes += ticket.hr();
    bytes += ticket.row([
      PosColumn(
          text: 'OR REF# $ornumber',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'DATE: $date',
          width: 6,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
    ]);

    bytes += ticket.hr();
    bytes += ticket.text('--Item List--',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
          text: 'DESCRIPTION',
          width: 9,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'QUANTITY',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
    ]);
    bytes += ticket.hr();
    for (int index = 0; index < items.length; index++) {
      bytes += ticket.row([
        PosColumn(
            text: '${items[index]['name']}',
            width: 9,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: '${items[index]['quantity']}',
            width: 3,
            styles: const PosStyles(align: PosAlign.center, bold: true)),
      ]);
    }

    bytes += ticket.feed(2);
    bytes += ticket.cut();
    return bytes;
  }

  Future<void> printOrderSlip() async {
    Map<String, dynamic> printerconfig = {};

    if (Platform.isAndroid) {
      printerconfig = await Helper().jsonToFileReadAndroid('printer.json');
    }

    if (Platform.isAndroid && printerconfig['isenable']) {
      PrinterNetworkManager printer =
          PrinterNetworkManager(printerconfig['productionprinterip']);
      PosPrintResult connect = await printer.connect();
      // TODO Don't forget to choose printer's paper
      PaperSize paper = printerconfig['papersize'] == 'mm80'
          ? PaperSize.mm80
          : PaperSize.mm58;
      final profile = await CapabilityProfile.load();

      if (connect == PosPrintResult.success) {
        PosPrintResult printing = await printer
            .printTicket((await orderSlipReceipt(paper, profile, items)));

        print(printing.msg);
        printer.disconnect();
      }
    }
  }
}
