import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart' as ble;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:fiveLPOS/model/shiftreport.dart';
import 'package:fiveLPOS/repository/customerhelper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:image/image.dart';
import 'package:flutter_bluetooth_basic/src/bluetooth_device.dart';

class EndShiftReceipt {
  ShiftReceiptModel report;
  NetworkPrinter printer;

  EndShiftReceipt(this.report, this.printer);

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
      pos = await Helper().JsonToFileRead('pos.json');
    }

    if (Platform.isWindows) {
      branch = await Helper().readJsonToFile('branch.json');
    }

    if (Platform.isAndroid) {
      branch = await Helper().JsonToFileRead('branch.json');
    }

    if (Platform.isWindows) {
      printerconfig = await Helper().readJsonToFile('printer.json');
    }

    if (Platform.isAndroid) {
      printerconfig = await Helper().JsonToFileRead('printer.json');
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
      final ByteData data = await rootBundle.load('assets/logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final Image? image = decodeImage(bytes);

      printer.drawer();
      printer.image(image!);
      printer.text(branchname,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));
      printer.text(address,
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.text(tin,
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.hr(len: 1);
      printer.feed(2);
      printer.text('Z-READING',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.feed(1);
      printer.row([
        PosColumn(
            text: 'DATE: ${report.date}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: 'POSID: ${report.pos}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      printer.row([
        PosColumn(
            text: 'SHIFT: ${report.shift}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: 'CASHIER: ${report.cashier}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      printer.hr(len: 1);
      printer.row([
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
      printer.row([
        PosColumn(
            text: 'SLS END: ${formatAsCurrency(report.salesending.toString())}',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: 'RCPT END: ${report.receiptending}',
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      printer.hr(len: 1);
      printer.text('--SOLD ITEMS--',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.row([
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
      printer.hr(len: 1);
      for (int index = 0; index < report.items.length; index++) {
        printer.row([
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
      printer.hr(len: 1);
      printer.text('--PAYMENTS SUMMARY--',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.hr(len: 1);
      for (int index = 0; index < report.summarypayments.length; index++) {
        printer.row([
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
      printer.hr(len: 1);
      printer.text('--STAFF SALES--',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.hr(len: 1);
      for (int index = 0; index < report.salesstaff.length; index++) {
        printer.row([
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
      printer.hr(len: 1);
      printer.text('--TOTAL SUMMARY--',
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.hr(len: 1);

      printer.row([
        PosColumn(
            text: 'TOTAL SALES',
            width: 6,
            styles: const PosStyles(align: PosAlign.left, bold: true)),
        PosColumn(
            text: formatAsCurrency(report.totalsales),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);

      printer.feed(2);
      printer.cut();
    }

    if (Platform.isAndroid && printerconfig['isbluetooth'] == true) {
      ble.PrinterBluetoothManager printerManager = ble.PrinterBluetoothManager();
      Map<String, dynamic> device = {
        'name': printerconfig['name'],
        'address': printerconfig['address'],
        'type': printerconfig['type'],
        'connected': true
      };
      BluetoothDevice bleDevice = BluetoothDevice.fromJson(device);
      ble.PrinterBluetooth bleprinter = ble.PrinterBluetooth(bleDevice);

      printerManager.selectPrinter(bleprinter);
      // TODO Don't forget to choose printer's paper
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();

      final ble.PosPrintResult res = await printerManager.printTicket(
          (await endshiftReport(
              paper, profile, branchname, id, serial, branchid, address, tin)));

      print(res.msg);
    }
  }
}
