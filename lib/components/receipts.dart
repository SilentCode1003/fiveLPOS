import 'dart:convert';

import 'package:fivelPOS/api/salesdetails.dart';
import 'package:fivelPOS/components/loadingspinner.dart';
import 'package:fivelPOS/model/receiptdescription.dart';
import 'package:fivelPOS/repository/customerhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';

import '../model/receipt.dart';

class ReceiptPage extends StatefulWidget {
  final Function reprint;
  final Function refund;
  final Function email;
  final String posid;

  const ReceiptPage({
    super.key,
    required this.reprint,
    required this.refund,
    required this.email,
    required this.posid,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  List<ReceiptModel> receipts = [];
  String currentdate = Helper().GetCurrentDate();

  final TextEditingController _refundReasonController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    getReceipts(currentdate, currentdate, widget.posid);
    super.initState();
  }

  Future<List<ReceiptModel>> getReceipts(datefrom, dateto, posid) async {
    await SalesDetails().getreceipts(datefrom, dateto, posid).then((result) {
      var jsonData = json.encode(result.data);
      if (result.status == 200) {
        setState(() {
          for (var data in json.decode(jsonData)) {
            print(data);

            ReceiptModel model = ReceiptModel(
              data['detail_id'],
              data['date'],
              data['pos_id'],
              data['shift'],
              data['payment_type'],
              data['description'],
              data['total'],
              data['cashier'],
              data['branch'],
              data['status'],
              data['tenderpaymenttype'],
              data['tenderamount'],
              data['epaymenttype'],
              data['referenceid'],
            );

            receipts.add(model);
          }
        });
      }
    });

    return receipts;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> receiptList = List<Widget>.generate(
        receipts.length,
        (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    List<ReceiptDescriptionModel> receiptDescription = [];
                    var description = receipts[index].description!;

                    for (var descrpt in jsonDecode(description)) {
                      receiptDescription.add(ReceiptDescriptionModel(
                        descrpt['id'],
                        descrpt['name'],
                        descrpt['price'],
                        descrpt['quantity'],
                        descrpt['stocks'],
                      ));
                    }

                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'OR: ${receipts[index].detailid}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${receipts[index].date} :DATE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    )
                                  ]),
                              Divider(
                                thickness: 4,
                                color: Colors.black,
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'CASHIER: ${receipts[index].cashier}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${receipts[index].cashier} :STAF',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    )
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'POS: ${receipts[index].posid}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '${receipts[index].shift}: SHIFT',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    )
                                  ]),
                              Divider(
                                thickness: 4,
                                color: Colors.black,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: DataTable(
                                      dividerThickness: 2,
                                      headingTextStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      headingRowColor:
                                          const WidgetStatePropertyAll(
                                              Colors.teal),
                                      dataTextStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      columns: const [
                                        DataColumn(label: Text('Description')),
                                        DataColumn(label: Text('Price')),
                                        DataColumn(label: Text('Quantity')),
                                        DataColumn(label: Text('Subtotal'))
                                      ],
                                      rows: receiptDescription
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        ReceiptDescriptionModel receipt =
                                            entry.value;

                                        return DataRow(cells: <DataCell>[
                                          DataCell(Text(receipt.productname)),
                                          DataCell(
                                              Text(receipt.price.toString())),
                                          DataCell(Text('${receipt.quantity}')),
                                          DataCell(Text(
                                              '${receipt.quantity * receipt.price}')),
                                        ]);
                                      }).toList()),
                                ),
                              ),
                              Divider(
                                thickness: 4,
                                color: Colors.black,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'PAYMENT: ${receipts[index].paymenttype}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'TOTAL: ${receipts[index].total}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'TYPE: ${receipts[index].tenderpaymenttype}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'REF#: ${receipts[index].referenceid}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        });
                  },
                  leading: const Icon(
                    Icons.receipt,
                    color: Colors.teal,
                    size: 40,
                  ),
                  title: Text(
                    'OR #: ${receipts[index].detailid!}\nTotal:${CurrencySymbols.PESO} ${toCurrencyString(receipts[index].total!)}\nDate:${receipts[index].date!}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(receipts[index].status!,
                      style: (receipts[index].status! == 'SOLD')
                          ? TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)
                          : TextStyle(
                              color: Colors.white,
                              backgroundColor: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.reprint(receipts[index].detailid!);
                        },
                        icon: Icon(Icons.print),
                        color: Colors.teal,
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'E-mail OR:${receipts[index].detailid!}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: TextField(
                                    controller: _emailAddressController,
                                    keyboardType: TextInputType.emailAddress,
                                    maxLength: 300,
                                    decoration: const InputDecoration(
                                        labelText: 'Email Address',
                                        hintText: 'Please enter email address'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return LoadingSpinner(
                                                  message: 'Sending...');
                                            });
                                        String email =
                                            _emailAddressController.text;
                                        dynamic result = await widget.email(
                                            email, receipts[index].detailid!);

                                        if (result == 'success') {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Success'),
                                                  content: const Text(
                                                      'E-Receipt sent successfully!'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('Ok'))
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                      child: const Text('Send'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: Icon(Icons.email),
                        color: Colors.teal,
                        iconSize: 40,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Refund OR:${receipts[index].detailid!}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: TextField(
                                    controller: _refundReasonController,
                                    keyboardType: TextInputType.multiline,
                                    maxLength: 300,
                                    decoration: const InputDecoration(
                                        labelText: 'Reason',
                                        hintText:
                                            'Please enter reason of refund'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        String reason =
                                            _refundReasonController.text;
                                        widget.refund(
                                            receipts[index].detailid!, reason);

                                        receipts = [];
                                        await SalesDetails()
                                            .getreceipts(currentdate,
                                                currentdate, widget.posid)
                                            .then((result) {
                                          var jsonData =
                                              json.encode(result.data);
                                          if (result.status == 200) {
                                            setState(() {
                                              for (var data
                                                  in json.decode(jsonData)) {
                                                print(data);

                                                ReceiptModel model =
                                                    ReceiptModel(
                                                  data['detail_id'],
                                                  data['date'],
                                                  data['pos_id'],
                                                  data['shift'],
                                                  data['payment_type'],
                                                  data['description'],
                                                  data['total'],
                                                  data['cashier'],
                                                  data['branch'],
                                                  data['status'],
                                                  data['tenderpaymenttype'],
                                                  data['tenderamount'],
                                                  data['epaymenttype'],
                                                  data['referenceid'],
                                                );

                                                receipts.add(model);
                                              }
                                            });

                                            Navigator.of(context).pop();
                                          }
                                        });
                                      },
                                      child: const Text('Proceed'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: Icon(Icons.refresh),
                        color: Colors.teal,
                        iconSize: 40,
                      ),
                    ],
                  ),
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
                    receipts = [];
                    await SalesDetails()
                        .getreceipts(currentdate, currentdate, widget.posid)
                        .then((result) {
                      var jsonData = json.encode(result.data);
                      if (result.status == 200) {
                        setState(() {
                          for (var data in json.decode(jsonData)) {
                            print(data);

                            ReceiptModel model = ReceiptModel(
                              data['detail_id'],
                              data['date'],
                              data['pos_id'],
                              data['shift'],
                              data['payment_type'],
                              data['description'],
                              data['total'],
                              data['cashier'],
                              data['branch'],
                              data['status'],
                              data['tenderpaymenttype'],
                              data['tenderamount'],
                              data['epaymenttype'],
                              data['referenceid'],
                            );

                            receipts.add(model);
                          }
                        });

                        Navigator.of(context).pop();
                      }
                    });
                  });
                }
              },
              child: Text(
                  '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}')),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: receipts.isEmpty
              ? [
                  const Center(
                    child: Text(
                      'No Data',
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                    ),
                  )
                ]
              : receiptList,
        ),
      ),
    );
  }
}
