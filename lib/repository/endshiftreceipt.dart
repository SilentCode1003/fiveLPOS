import 'dart:convert';
import 'dart:io';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue/gen/flutterblue.pbserver.dart' as pbserver;

import '/model/shiftreport.dart';
import '/repository/customerhelper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:image/image.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class EndShiftReceipt {
  ShiftReceiptModel report;

  EndShiftReceipt(this.report);

  String formatAsCurrency(dynamic value) {
    return toCurrencyString(
      value.toString(), mantissaLength: 2,
      // leadingSymbol: CurrencySymbols.
    );
  }

  Future<List<int>> endshiftReport(PaperSize paper, CapabilityProfile profile,
      branchname, id, serial, branchid, address, tin) async {
    final Generator printer = Generator(paper, profile);
    List<int> bytes = [];

    final ByteData data = await rootBundle.load('assets/logo.png');
    final Uint8List imagebytes = data.buffer.asUint8List();
    final Image? image = decodeImage(imagebytes);

    bytes += printer.drawer();
    bytes += printer.image(image!);
    bytes += printer.text(branchname,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += printer.text(address,
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += printer.text(tin,
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += printer.hr();
    bytes += printer.feed(2);
    bytes += printer.text('Z-READING',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += printer.feed(1);
    bytes += printer.row([
      PosColumn(
          text: 'DATE: ${report.date}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'POSID: ${report.pos}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += printer.row([
      PosColumn(
          text: 'SHIFT: ${report.shift}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'CASHIER: ${report.cashier}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += printer.hr();
    bytes += printer.row([
      PosColumn(
          text:
              'SLS BEG: ${formatAsCurrency(report.salesbeginning.toString())}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'RCPT BEG: ${report.receiptbeginning}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += printer.row([
      PosColumn(
          text: 'SLS END: ${formatAsCurrency(report.salesending.toString())}',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'RCPT END: ${report.receiptending}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += printer.hr();
    bytes += printer.text('--SOLD ITEMS--',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += printer.row([
      PosColumn(
          text: 'DESC',
          width: 4,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'QTY',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'PRC',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'TOTAL',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += printer.hr();
    for (int index = 0; index < report.items.length; index++) {
      bytes += printer.row([
        PosColumn(
            text: '${report.items[index].item}',
            width: 4,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: '${report.items[index].quantity}',
            width: 2,
            styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(
            text: '${report.items[index].price}',
            width: 3,
            styles: const PosStyles(align: PosAlign.center, bold: true)),
        PosColumn(
            text: formatAsCurrency(report.items[index].total.toString()),
            width: 3,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
    }
    bytes += printer.hr();
    bytes += printer.text('--PAYMENTS SUMMARY--',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += printer.hr();
    for (int index = 0; index < report.summarypayments.length; index++) {
      bytes += printer.row([
        PosColumn(
            text: '${report.summarypayments[index].paymenttype}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: formatAsCurrency(
                report.summarypayments[index].total.toString()),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
    }
    bytes += printer.hr();
    bytes += printer.text('--STAFF SALES--',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += printer.hr();
    for (int index = 0; index < report.salesstaff.length; index++) {
      bytes += printer.row([
        PosColumn(
            text: '${report.salesstaff[index].salesstaff}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: formatAsCurrency(report.salesstaff[index].total.toString()),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
    }
    bytes += printer.hr();
    bytes += printer.text('--TOTAL SUMMARY--',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += printer.hr();

    bytes += printer.row([
      PosColumn(
          text: 'TOTAL SALES',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: formatAsCurrency(report.totalsales),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);

    bytes += printer.feed(2);
    bytes += printer.cut();
    return bytes;
  }

  Future<void> printZReading() async {
    String id = '';
    String posname = '';
    String serial = '';
    String min = '';
    String ptu = '';

    String branchid = '';
    String branchname = '';
    String tin = '';
    String address = '';
    List<String> logo = [];

    Map<String, dynamic> printerconfig = {};
    Map<String, dynamic> pos = {};
    Map<String, dynamic> branch = {};

    if (Platform.isWindows) {
      pos = await Helper().readJsonToFile('pos.json');
    }

    if (Platform.isAndroid) {
      pos = await Helper().jsonToFileReadAndroid('pos.json');
    }

    if (Platform.isWindows) {
      branch = await Helper().readJsonToFile('branch.json');
    }

    if (Platform.isAndroid) {
      branch = await Helper().jsonToFileReadAndroid('branch.json');
    }

    if (Platform.isWindows) {
      printerconfig = await Helper().readJsonToFile('printer.json');
    }

    if (Platform.isAndroid) {
      printerconfig = await Helper().jsonToFileReadAndroid('printer.json');
    }

    id = pos['posid'].toString();
    posname = pos['posname'];
    serial = pos['serial'];
    min = pos['min'];
    ptu = 'PTU: ${pos['ptu']}';

    branchid = branch['branchid'].toString();
    branchname = branch['branchname'];
    tin = 'VAT REG TIN: ${branch['tin']}';
    address = branch['address'];
    logo = utf8.decode(base64.decode(branch['logo'])).split('<svg');

    if (Platform.isAndroid && printerconfig['isenable']) {
      PrinterNetworkManager printer =
          PrinterNetworkManager(printerconfig['printerip']);
      PosPrintResult connect = await printer.connect();
      // TODO Don't forget to choose printer's paper
      PaperSize paper = printerconfig['papersize'] == 'mm80'
          ? PaperSize.mm80
          : PaperSize.mm58;
      final profile = await CapabilityProfile.load();

      if (connect == PosPrintResult.success) {
        PosPrintResult printing = await printer.printTicket(
            (await endshiftReport(paper, profile, branchname, id, serial,
                branchid, address, tin)));

        print(printing.msg);
      }
    }

    // if (Platform.isAndroid && printerconfig['isbluetooth'] == true) {
    //   PrinterBluetoothManager printerManager = PrinterBluetoothManager();
    //   // Map<String, dynamic> device = {
    //   //   'name': printerconfig['name'],
    //   //   'address': printerconfig['address'],
    //   //   'type': printerconfig['type'],
    //   //   'connected': true
    //   // };
    //   // BluetoothDevice bleDevice = BluetoothDevice.fromJson(device);

    //   var blePrinter = pbserver.BluetoothDevice()
    //     ..remoteId = printerconfig['address']
    //     ..name = printerconfig['name']
    //     ..type = printerconfig['type'];

    //   var printerBle = BluetoothDevice.fromProto(blePrinter);

    //   printerManager.selectPrinter(PrinterBluetooth(printerBle));
    //   // TODO Don't forget to choose printer's paper
    //   PaperSize paper = printerconfig['papersize'] == 'mm80'
    //       ? PaperSize.mm80
    //       : PaperSize.mm58;
    //   final profile = await CapabilityProfile.load();

    //   final PosPrintResult res = await printerManager.printTicket(
    //       (await endshiftReport(
    //           paper, profile, branchname, id, serial, branchid, address, tin)));

    //   print(res.msg);
    // }
  }
}
