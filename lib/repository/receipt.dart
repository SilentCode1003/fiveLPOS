import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos2/repository/customerhelper.dart';
import 'package:pos2/repository/dbhelper.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../model/branch.dart';

class Receipt {
  List<Map<String, dynamic>> items;
  double cash;
  String detailid;
  String posid;
  String cashier;
  String shift;
  String companyname;
  String address;
  String tin;

  Receipt(this.items, this.cash, this.detailid, this.posid, this.cashier,
      this.shift, this.companyname, this.address, this.tin);

  Helper helper = Helper();
  DatabaseHelper dbHelper = DatabaseHelper();

  String formatAsCurrency(double value) {
    return toCurrencyString(
      value.toString(), mantissaLength: 2,
      // leadingSymbol: CurrencySymbols.
    );
  }
  //Currency

  // Future<void> getConfig() async {
  //   String filePath = 'assets/branch.json';

  //   String results = await Helper().readJsonFile(filePath);
  //   List<dynamic> jsonData = json.decode(results);
  //   List<BranchModel> model = jsonData
  //       .map((data) => BranchModel(data['branchid'], data['branchname'],
  //           data['tin'], data['address'], data['logo']))
  //       .toList();
  // }

  String businessname() {
    return companyname;
  }

  String businessadd() {
    return address;
  }

  String cartitems() {
    return '00000 00000 00000 00000';
  }

  String vatreg() {
    return 'VAT REG TIN: $tin';
  }

/////INFO//////
  String datetime() {
    return helper.GetCurrentDatetime();
  }

  String officialreceipt() {
    return detailid;
  }

  String staffname() {
    return cashier;
  }

  String posnumber() {
    return posid;
  }

  String serialnum() {
    return '4585452';
  }

  String branchname() {
    return 'Pacita';
  }

  String minnum() {
    return '23031410403868315';
  }

  ////////MIDDLE//////
  String itemquantity() {
    return 'x5';
  }

  ////////Numbers//////
  double totalamtdue(List<Map<String, dynamic>> items) {
    double total = 0;
    for (int index = 0; index < items.length; index++) {
      total += (items[index]['price'] * items[index]['quantity']);
    }

    return total;
  }

  String customercash(cash) {
    return formatAsCurrency(cash);
  }

  String change(total, cash) {
    double change = (cash - total);

    return formatAsCurrency(change);
  }

  double vatable(total) {
    double vatable = (total / 1.12);

    return double.parse(vatable.toStringAsFixed(2));
  }

  String vatamt(total, vatable) {
    double vat = (total - vatable);

    return formatAsCurrency(vat);
  }

  String vatexemptsales() {
    return '0.00';
  }

  String zerorated() {
    return '0.00';
  }

  ////////Sold To//////

  ////////Footer//////
  String tinnum() {
    return '000-000-000-000';
  }

  String biraccr() {
    return '1160003801882018081144';
  }

  String accrdate() {
    return 'test';
  }

  String permitnum() {
    return 'FP032023-116-0375318-000000';
  }

//////others///////
  String promorgimmicks() {
    return 'present the receipt to claim a freebie test';
  }

  Future<Uint8List> printReceipt() async {
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

    PdfPageFormat format = PdfPageFormat.roll80;
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    Database db = await dbHelper.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');
    for (var pos in posconfig) {
      id = pos['posid'].toString();
      posname = pos['posname'];
      serial = pos['serial'];
      min = pos['min'];
      ptu = pos['ptu'];
    }

    List<Map<String, dynamic>> branchconfig = await db.query('branch');
    for (var branch in branchconfig) {
      branchid = branch['branchid'].toString();
      branchname = branch['branchname'];
      tin = 'VAT REG TIN: ${branch['tin']}';
      address = branch['address'];
      logo = utf8.decode(base64.decode(branch['logo'])).split('<svg');

      print('${logo[0]}\n\n${logo[1]}');
    }

    // await getConfig();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.SizedBox(
                  child: pw.Flexible(
                    child: pw.SvgImage(svg: '<svg ${logo[1]}'),
                  ),
                  height: 50,
                  width: 50),
              pw.SizedBox(height: 10),
              pw.Text(
                branchname,
                style: const pw.TextStyle(fontSize: 18),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                address,
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                tin,
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),

              //////////////////////////////////////////////////////////////////////////////////////////
              pw.Container(
                height: 1, // Set the height of the divider
                color: PdfColors.black, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 10), // Adjust vertical spacing
              ),
              pw.Text(
                datetime(),
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'OR: ${officialreceipt()}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Staff: ${staffname()}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'POS: $id',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'SN#: $serial',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Branch: $branchid',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'MIN: $min',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 1),
              pw.Container(
                height: 1, // Set the height of the divider
                color: PdfColors.black, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 7), // Adjust vertical spacing
              ),
              //////////////////////////////////////////////////////////////////////////////////////////
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Description',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Amount',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),

              for (int index = 0; index < items.length; index++)
                pw.Row(
                  children: [
                    pw.Container(
                      width: 100,
                      child: pw.Text(
                        ' ${items[index]['name']} @ ${items[index]['quantity']}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                    pw.Container(
                      width: 100,
                      child: pw.Text(
                        formatAsCurrency(
                            items[index]['quantity'] * items[index]['price']),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ),
                  ],
                ),
              pw.SizedBox(height: 6),
              pw.Container(
                height: 1, // Set the height of the divider
                color: PdfColors.grey700, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 5), // Adjust vertical spacing
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Total Amount Due:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      formatAsCurrency(totalamtdue(items)),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Cash:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      customercash(cash),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Change:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      change(totalamtdue(items), cash),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Vatable:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      formatAsCurrency(vatable(totalamtdue(items))),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'VAT Amt:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      vatamt(totalamtdue(items), vatable(totalamtdue(items))),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'VAT Exempt Sales:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      vatexemptsales(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      'Zero Rated:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.Container(
                    width: 100,
                    child: pw.Text(
                      zerorated(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 0.5, // Set the height of the divider
                color: PdfColors.grey700, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 5), // Adjust vertical spacing
              ),
              pw.SizedBox(height: 6),
              pw.Column(children: [
                pw.Text(
                  'Sold to:____________________',
                  textAlign: pw.TextAlign.left,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Address:____________________',
                  textAlign: pw.TextAlign.left,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'TIN:________________________',
                  textAlign: pw.TextAlign.left,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'THIS IS A OFFICIAL RECEIPT',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ]),
              //////OTHERS//////////
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
