import 'dart:convert';

import 'package:fivelPOS/repository/customerhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

import '../api/shiftreport.dart';
import '../model/shiftreport.dart';
import '../repository/endshiftreceipt.dart';
import 'loadingspinner.dart';

class ReportPage extends StatefulWidget {
  final String posid;
  const ReportPage({super.key, required this.posid});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<ShiftReportModel> reports = [];
  String currentdate = Helper().GetCurrentDate();
  @override
  void initState() {
    // TODO: implement initState
    getShiftReport(currentdate, widget.posid);

    super.initState();
  }

  Future<List<ShiftReportModel>> getShiftReport(date, posid) async {
    reports = [];
    await ShiftReportAPI().getShiftReports(date, posid).then((result) {
      var jsonData = json.encode(result.data);
      if (result.status == 200) {
        setState(() {
          for (var data in json.decode(jsonData)) {
            print(data);
            ShiftReportModel model = ShiftReportModel(
                data['date'],
                data['pos'],
                data['shift'],
                data['cashier'],
                data['floating'],
                data['cashfloat'],
                data['sales_beginning'],
                data['sales_ending'],
                data['total_sales'],
                data['receipt_beginning'],
                data['receipt_ending'],
                data['status'],
                data['approvedby'],
                data['approveddate']);
            reports.add(model);
          }
        });
      }
    });

    return reports;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> reportList = List<Widget>.generate(
        reports.length,
        (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt,
                    color: Colors.teal,
                    size: 40,
                  ),
                  title: Text(
                    'POS ID: ${reports[index].pos}\nSHIFT NO.: ${reports[index].shift}\nDate: ${reports[index].date}\nTotal Sales: ${CurrencySymbols.PESO} ${toCurrencyString(reports[index].totalsales)}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${reports[index].status}',
                      style: (reports[index].status == 'APPROVED')
                          ? TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)
                          : TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.orange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                      onPressed: () async {
                        List<SoldItemModel> shiftsolditems = [];
                        List<SummaryPaymentModel> shiftsummarypayment = [];
                        List<StaffSalesModel> shiftstaffsales = [];

                        final solditems = await ShiftReportAPI()
                            .getShiftItemSold(reports[index].receiptbeginning,
                                reports[index].receiptending);
                        final solditemJson = json.encode(solditems['data']);

                        for (var data in json.decode(solditemJson)) {
                          setState(() {
                            shiftsolditems.add(SoldItemModel(
                                data['item'],
                                data['price'],
                                data['quantity'],
                                data['total']));
                          });
                        }

                        final summarypayment = await ShiftReportAPI()
                            .getShiftSummaryPayment(
                                reports[index].receiptbeginning,
                                reports[index].receiptending);
                        final summarypaymentJson =
                            json.encode(summarypayment['data']);

                        for (var data in json.decode(summarypaymentJson)) {
                          setState(() {
                            shiftsummarypayment.add(SummaryPaymentModel(
                                data['paymenttype'], data['total']));
                          });
                        }

                        final staffsales = await ShiftReportAPI()
                            .getShiftStaffSales(reports[index].receiptbeginning,
                                reports[index].receiptending);
                        final staffsalesJson = json.encode(staffsales['data']);

                        for (var data in json.decode(staffsalesJson)) {
                          setState(() {
                            shiftstaffsales.add(StaffSalesModel(
                                data['salesstaff'], data['total']));
                          });
                        }

                        await EndShiftReceipt(ShiftReceiptModel(
                          reports[index].date,
                          reports[index].pos,
                          reports[index].shift,
                          reports[index].cashier,
                          reports[index].salesbeginning,
                          reports[index].salesbeginning,
                          reports[index].totalsales,
                          reports[index].receiptbeginning,
                          reports[index].receiptending,
                          shiftsolditems,
                          shiftsummarypayment,
                          shiftstaffsales,
                        )).printZReading();
                      },
                      icon: const Icon(
                        Icons.print,
                        color: Colors.teal,
                        size: 40,
                      )),
                ),
              ),
            ));

    DateTime selectedDate = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Align(
          alignment: Alignment.center,
          child: OutlinedButton(
              style: const ButtonStyle(
                  fixedSize: WidgetStatePropertyAll(Size(220, 70)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white)),
              onPressed: () async {
                final DateTime? dateTime = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(3000));

                if (dateTime != null) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LoadingSpinner(message: 'Loading...');
                      });

                  setState(() async {
                    selectedDate = dateTime;
                    currentdate = DateFormat('yyyy-MM-dd').format(selectedDate);
                    reports = [];
                    await ShiftReportAPI()
                        .getShiftReports(currentdate, widget.posid)
                        .then((result) {
                      var jsonData = json.encode(result.data);
                      if (result.status == 200) {
                        setState(() {
                          for (var data in json.decode(jsonData)) {
                            print(data);

                            ShiftReportModel model = ShiftReportModel(
                                data['date'],
                                data['pos'],
                                data['shift'],
                                data['cashier'],
                                data['floating'],
                                data['cashfloat'],
                                data['sales_beginning'],
                                data['sales_ending'],
                                data['total_sales'],
                                data['receipt_beginning'],
                                data['receipt_ending'],
                                data['status'],
                                data['approvedby'],
                                data['approveddate']);
                            reports.add(model);
                          }
                        });

                        Navigator.of(context).pop();
                      }
                    });
                  });
                }
              },
              child: Text(currentdate)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: reportList.isEmpty
              ? [
                  const Center(
                    child: Text(
                      "No Data",
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                    ),
                  )
                ]
              : reportList,
        ),
      ),
    );
  }
}
