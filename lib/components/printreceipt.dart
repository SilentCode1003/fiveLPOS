import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos2/repository/customerhelper.dart';
import 'package:pos2/repository/dbhelper.dart';
import 'package:printing/printing.dart';
import 'package:sqflite_common/sqlite_api.dart';

class PrintReceipt extends StatefulWidget {
  const PrintReceipt({super.key});

  @override
  State<PrintReceipt> createState() => _PrintReceiptState();
}

class _PrintReceiptState extends State<PrintReceipt> {
  Helper helper = Helper();
  DatabaseHelper dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfPreview(
          build: (format) => _receipt(format),
          onPrinted: (context) => () {
                Navigator.of(context).pop();
                // MaterialPageRoute(builder: (context) => const MyDashboard());
              }),
    );
  }

  _receipt(PdfPageFormat format) async {
    String id = '';
    String posname = '';
    String serial = '';
    String min = '';
    String ptu = '';

    String branchid = '';
    String branchname = '';
    String tin = '';
    List<String> address = [];
    List<String> logo = [];

    PdfPageFormat format = PdfPageFormat.roll80;
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    Database db = await dbHelper.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');
    for (var pos in posconfig) {
      id = pos['posid'].toString();
      posname = pos['posname'];
      serial = pos['serial'];
      min = pos['min'];
      ptu = 'PTU: ${pos['ptu']}';
    }

    List<Map<String, dynamic>> branchconfig = await db.query('branch');
    for (var branch in branchconfig) {
      branchid = branch['branchid'].toString();
      branchname = branch['branchname'];
      tin = 'VAT REG TIN: ${branch['tin']}';
      address = branch['address'].toString().split(',').toList();
      logo = utf8.decode(base64.decode(branch['logo'])).split('<svg');
    }

    return pdf.save();
  }
}
