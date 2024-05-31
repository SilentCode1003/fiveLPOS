import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '/api/addon.dart';
import '/api/employees.dart';
import '/api/package.dart';
import '/api/services.dart';
import '/api/shiftreport.dart';
import '/components/settings.dart';
import '/model/addon.dart';
import '/model/category.dart';
import '/model/servicepackage.dart';
import '/model/services.dart';
import '/model/shiftreport.dart';
import '/repository/endshiftreceipt.dart';
import '/repository/orderslip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/api/discount.dart';
import '/api/payment.dart';
import '/api/posshiftlog.dart';
import '/components/loadingspinner.dart';
import '/model/productprice.dart';
import '/api/category.dart';
import '/repository/customerhelper.dart';
import '/api/salesdetails.dart';
import '/api/productprice.dart';
import '/repository/dbhelper.dart';
import '/repository/email.dart';
import '/repository/receipt.dart';
import '/api/transaction.dart';
import '/repository/reprint.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class ButtonStyleInfo {
  final Color backgroundColor;
  final Color textColor;

  ButtonStyleInfo({
    required this.backgroundColor,
    required this.textColor,
  });
}

class MyDashboard extends StatefulWidget {
  final String employeeid;
  final String fullname;
  final int accesstype;
  final int positiontype;
  final String logo;

  const MyDashboard(
      {super.key,
      required this.employeeid,
      required this.fullname,
      required this.accesstype,
      required this.positiontype,
      required this.logo});

  @override
  _MyDashboardState createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  List<Map<String, dynamic>> itemsList = [];
  List<ProductPriceModel> productList = [];
  List<CategoryModel> categoryList = [];
  List<ServiceModel> serviceList = [];
  List<ServicePackageModel> packageList = [];
  List<AddonModel> addonList = [];
  List<String> discountList = [];
  List<String> paymentList = [];
  String companyname = '';
  String address = '';
  String tin = '';
  String posid = '';
  String shift = '';
  String branchid = '';
  bool isStartShift = false;
  bool isEndShift = false;
  String businessdate = '';
  List<Map<String, dynamic>> discountDetail = [];
  List<SoldItemModel> shiftsolditems = [];
  List<SummaryPaymentModel> shiftsummarypayment = [];
  List<StaffSalesModel> shiftstaffsales = [];

  double splitcash = 0;
  double splitepayamount = 0;
  double remaining = 0;
  int discountItemCounter = 0;

  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _referenceidController = TextEditingController();
  final TextEditingController _receiptORController = TextEditingController();
  final TextEditingController _splitCashController = TextEditingController();
  final TextEditingController _splitReferenceidController =
      TextEditingController();
  final TextEditingController _splitAmountController = TextEditingController();
  final TextEditingController _discountFullnameController =
      TextEditingController();
  final TextEditingController _discountIDController = TextEditingController();
  // final TextEditingController _salesrepresentativeController =
  //     TextEditingController();
  final TextEditingController _cashReceivedController = TextEditingController();
  Helper helper = Helper();
  DatabaseHelper dbHelper = DatabaseHelper();
  int detailid = 100000000;

  String branchlogo = '';
  // String branchlogo = '';

  String salesrepresentative = '';
  List<String> employees = [];

  final TextEditingController _searchController = TextEditingController();
  List<ProductPriceModel> filteredList = [];

  final TextEditingController _refundORController = TextEditingController();
  final TextEditingController _refundReasonController = TextEditingController();

//printer parameters
  @override
  void initState() {
    // TODO: implement initState
    _getbranchdetail();
    _getposconfig();
    _getcategory();
    _getdiscount();
    _getpayment();
    _getemployees();
    // _getbranchdetail();

    super.initState();
  }

  @override
  void dispose() {
    _splitCashController.dispose();
    _splitAmountController.dispose();
    _searchController.dispose();
    _refundORController.dispose();
    _refundReasonController.dispose();
    super.dispose();
  }

// #region API CALLS

  Future<void> _getbranchdetail() async {
    // Database db = await dbHelper.database;
    // List<Map<String, dynamic>> branchconfig = await db.query('branch');
    Map<String, dynamic> branch = {};

    if (Platform.isWindows) {
      branch = await Helper().readJsonToFile('branch.json');

      setState(() {
        List<String> logo =
            utf8.decode(base64.decode(branch['logo'])).split('<svg ');
        String svglogo = '<svg ${logo[1].replaceAll(RegExp(r'\n'), ' ')}';

        branchlogo = svglogo;
        companyname = branch['branchname'];
      });
    }

    if (Platform.isAndroid) {
      branch = await Helper().JsonToFileRead('branch.json');

      setState(() {
        List<String> logo =
            utf8.decode(base64.decode(branch['logo'])).split('<svg ');
        String svglogo = '<svg ${logo[1].replaceAll(RegExp(r'\n'), ' ')}';

        branchlogo = svglogo;
        companyname = branch['branchname'];
      });
    }
    // for (var branch in branchconfig) {

    // }
  }

  Future<void> _getPOSShift(posid) async {
    final results = await POSShiftLogAPI().getPOSShift(posid);
    final jsonData = json.encode(results['data']);

    print(jsonData);

    if (jsonData.length == 2) {
      print('empty');
      setState(() {
        isStartShift = true;
        isEndShift = false;
      });
    }

    for (var data in json.decode(jsonData)) {
      print('processing');
      businessdate = data['date'];
      shift = data['shift'];
      if (data['status'] != 'START') {
        setState(() {
          isStartShift = true;
        });
      } else {
        setState(() {
          isEndShift = true;
        });
      }
    }

    print('Start Shift: $isStartShift');
    print('End Shift: $isEndShift');
  }

  Future<void> _startShift(BuildContext context, posid) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    final results = await POSShiftLogAPI()
        .startShift(posid, widget.fullname, (detailid + 1).toString());
    // final jsonData = json.encode(results['data']);
    print(results['msg']);

    if (results['msg'] == 'success') {
      setState(() {
        isStartShift = false;
      });
    }
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Shift started!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _getPOSShift(posid);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    });
  }

  Future<void> _endShift(BuildContext context, posid) async {
    String receiptbeginning = '';
    String receiptending = '';
    String totalsales = '';
    String salesbeginning = '';
    String salesending = '';

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    final results = await POSShiftLogAPI().endShift(posid, detailid.toString());
    // final jsonData = json.encode(results['data']);
    print(results['msg']);

    if (results['msg'] == 'success') {
      setState(() {
        isStartShift = false;
      });

      final shiftreport =
          await ShiftReportAPI().getShiftReport(businessdate, posid, shift);
      final shiftreportJson = json.encode(shiftreport['data']);

      print(shiftreport);

      for (var data in json.decode(shiftreportJson)) {
        ShiftReportModel report = ShiftReportModel(
            data['date'],
            data['pos'],
            data['shift'],
            data['cashier'],
            data['floating'],
            data['cashfloat'],
            data['salesbeginning'],
            data['salesending'],
            data['totalsales'],
            data['receiptbeginning'],
            data['receiptending'],
            data['status'],
            data['approvedby'],
            data['approveddate']);
        setState(() {
          receiptbeginning = report.receiptbeginning;
          receiptending = report.receiptending;
          totalsales = report.totalsales.toString();
          salesbeginning = report.salesbeginning;
          salesending = report.salesending;
        });
      }

      print('begin:$receiptbeginning end:$receiptending');

      final solditems = await ShiftReportAPI()
          .getShiftItemSold(receiptbeginning, receiptending);
      final solditemJson = json.encode(solditems['data']);

      for (var data in json.decode(solditemJson)) {
        setState(() {
          shiftsolditems.add(SoldItemModel(
              data['item'], data['price'], data['quantity'], data['total']));
        });
      }

      print(shiftsolditems);

      final summarypayment = await ShiftReportAPI()
          .getShiftSummaryPayment(receiptbeginning, receiptending);
      final summarypaymentJson = json.encode(summarypayment['data']);

      for (var data in json.decode(summarypaymentJson)) {
        setState(() {
          shiftsummarypayment
              .add(SummaryPaymentModel(data['paymenttype'], data['total']));
        });
      }

      print(shiftsummarypayment);

      final staffsales = await ShiftReportAPI()
          .getShiftStaffSales(receiptbeginning, receiptending);
      final staffsalesJson = json.encode(staffsales['data']);

      for (var data in json.decode(staffsalesJson)) {
        setState(() {
          shiftstaffsales
              .add(StaffSalesModel(data['salesstaff'], data['total']));
        });
      }

      print(shiftstaffsales);
    }

    await EndShiftReceipt(ShiftReceiptModel(
            businessdate,
            posid,
            shift,
            widget.fullname,
            salesbeginning,
            salesending,
            totalsales,
            receiptbeginning,
            receiptending,
            shiftsolditems,
            shiftsummarypayment,
            shiftstaffsales))
        .printZReading();

    _clearItems();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Shift Ended!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _getPOSShift(posid);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    });
  }

  Future<void> _getdetails(BuildContext context, detailid) async {
    try {
      final results = await SalesDetails().getdetails(detailid);
      final jsonData = json.encode(results['data']);

      print(jsonData);

      if (jsonData.length == 2) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Not Found'),
                content: Text('OR Number $detailid not found'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      } else {
        dynamic cash = 0;
        dynamic ecash = 0;
        String ornumber = '';
        String ordate = '';
        String ordescription = '';
        String orpaymenttype = '';
        String posid = '';
        String shift = '';
        String cashier = '';
        String total = '';
        String epaymentname = '';
        String referenceid = '';
        for (var data in json.decode(jsonData)) {
          print(data['orpaymenttype']);
          setState(() {
            ornumber = data['ornumber'];
            ordate = data['ordate'];
            ordescription = data['ordescription'];
            orpaymenttype = data['orpaymenttype'];
            posid = data['posid'];
            shift = data['shift'];
            cashier = data['cashier'];
            total = data['total'];
            epaymentname = data['paymentmethod'];
            referenceid = data['referenceid'];

            if (orpaymenttype == 'SPLIT') {
              print(orpaymenttype);
              if (data['paymentmethod'] != 'Cash') {
                ecash = data['amount'];
              } else {
                cash = data['amount'];
              }
            } else {
              cash = data['amount'];
            }
          });
        }

        final pdfBytes = await ReprintingReceipt(
                ornumber,
                ordate,
                ordescription,
                orpaymenttype,
                posid,
                shift,
                cashier,
                double.parse(total),
                epaymentname,
                referenceid,
                cash.toDouble(),
                ecash.toDouble())
            .printReceipt();

        if (Platform.isWindows) {
          List<Printer> printerList = await Printing.listPrinters();
          for (var printer in printerList) {
            if (printer.isDefault) {
              Printing.directPrintPdf(
                  printer: printer,
                  onLayout: (PdfPageFormat format) => pdfBytes);
            }
          }
        }

        if (Platform.isAndroid) {
          // Printing.layoutPdf(
          //   onLayout: (PdfPageFormat format) async => pdfBytes,
          // );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> _sendreceipt(email, ornumber) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    final results = await SalesDetails().getdetails(ornumber);
    final jsonData = json.encode(results['data']);

    if (results['msg'] == 'success') {
      Navigator.of(context).pop();
      if (jsonData.length == 2) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Not Found'),
                content: Text('OR Number $detailid not found'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });

        return 'notfound';
      } else {
        int cash = 0;
        int ecash = 0;
        String ornumber = '';
        String ordate = '';
        String ordescription = '';
        String orpaymenttype = '';
        String posid = '';
        String shift = '';
        String cashier = '';
        String total = '';
        String epaymentname = '';
        String referenceid = '';
        for (var data in json.decode(jsonData)) {
          print(data);
          setState(() {
            ornumber = data['ornumber'];
            ordate = data['ordate'];
            ordescription = data['ordescription'];
            orpaymenttype = data['orpaymenttype'];
            posid = data['posid'];
            shift = data['shift'];
            cashier = data['cashier'];
            total = data['total'];
            epaymentname = data['epaymentname'];
            referenceid = data['referenceid'];

            if (orpaymenttype == 'SPLIT') {
              if (data['paymentmethod'] != 'CASH') {
                ecash = data['amount'];
              } else {
                cash = data['amount'];
              }
            } else {
              cash = data['amount'];
            }
          });
        }

        final pdfBytes = await ReprintingReceipt(
          ornumber,
          ordate,
          ordescription,
          orpaymenttype,
          posid,
          shift,
          cashier,
          double.parse(total),
          epaymentname,
          referenceid,
          cash.toDouble(),
          ecash.toDouble(),
        ).printReceipt();

        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(jsonDecode(ordescription));

        await Email().sendMail(ornumber, email, pdfBytes, cashier, items,
            epaymentname, referenceid);
      }
    }
    return 'success';
  }

  Future<void> _getposconfig() async {
    // Database db = await dbHelper.database;
    // List<Map<String, dynamic>> posconfig = await db.query('pos');

    if (Platform.isWindows) {
      Map<String, dynamic> pos = await Helper().readJsonToFile('pos.json');
      // for (var pos in posconfig) {
      setState(() {
        posid = pos['posid'].toString();
        print(posid);
        _getdetailid(posid);
        _getPOSShift(posid);
      });
      // }
      Map<String, dynamic> branch =
          await Helper().readJsonToFile('branch.json');
      // List<Map<String, dynamic>> branchconfig = await db.query('branch');
      // for (var branch in branchconfig) {
      setState(() {
        branchid = branch['branchid'].toString();
      });
      // }
    }

    if (Platform.isAndroid) {
      Map<String, dynamic> pos = await Helper().JsonToFileRead('pos.json');
      // for (var pos in posconfig) {
      setState(() {
        posid = pos['posid'].toString();
        print(posid);
        _getdetailid(posid);
        _getPOSShift(posid);
      });
      // }
      Map<String, dynamic> branch =
          await Helper().JsonToFileRead('branch.json');
      // List<Map<String, dynamic>> branchconfig = await db.query('branch');
      // for (var branch in branchconfig) {
      setState(() {
        branchid = branch['branchid'].toString();
      });
      // }
    }
  }

  Future<void> _search() async {
    String serial = _serialNumberController.text;
    final results = await ProductPrice().getitemserial(serial, branchid);
    final jsonData = json.decode(results['data']);
    int id = 0;
    String description = '';
    double price = 0;
    double stocks = 0;

    print('Data Length: ${jsonData.length}');

    if (jsonData.length != 0) {
      setState(() {
        for (var data in jsonData) {
          print(data);
          id = data['id'];
          description = data['description'];
          price = double.parse(data['price'].toString());
          stocks = double.parse(data['quantity'].toString());
          addItem(id, description, price, 1, stocks);
        }
      });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Alert'),
              content: Text(
                  'Item not found with SN:${_serialNumberController.text}'),
              icon: const Icon(Icons.warning),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
  }

  Future<void> _getcategory() async {
    final results = await CategoryAPI().getCategory();
    final jsonData = json.encode(results['data']);
    setState(() {
      for (var data in json.decode(jsonData)) {
        if (data['categoryname'] == 'Material') {
        } else {
          categoryList.add(CategoryModel(
              data['categorycode'],
              data['categoryname'],
              data['status'],
              data['createdby'],
              data['createddate']));
        }
      }
    });
  }

  Future<void> _getcategoryitems(int category) async {
    final result =
        await ProductPrice().getcategoryitems(category.toString(), branchid);
    final jsonData = json.decode(result['data']);

    if (result['msg'] == 'success') {
      setState(() {
        productList.clear();
        // productList =
        //     jsonData.map((data) => ProductPriceModel.fromJson(data)).toList();

        for (var data in jsonData) {
          productList.add(ProductPriceModel(
              data['productid'],
              data['description'],
              data['barcode'],
              data['productimage'],
              data['price'],
              data['category'],
              data['quantity']));
        }
      });
    }
  }

  Future<void> _getdetailid(String pos) async {
    final result = await SalesDetails().getdetailid(pos);
    int id = int.parse(result['data']);

    print(id);

    setState(() {
      detailid = id;
      print(detailid);
    });
  }

  Future<void> _getdiscountrate(type) async {
    final results = await DiscountAPI().getDiscountRate(type);
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        double discount = (calculateGrandTotal() * (data['rate'] / 100)) * -1;

        if (calculateGrandTotal() == 0) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Discount'),
                  content:
                      const Text('Can not do discount if empty transaction'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              });
        } else {
          String fullname = _discountFullnameController.text == ''
              ? 'N/A'
              : _discountFullnameController.text;
          String id = _discountIDController.text == ''
              ? 'N/A'
              : _discountIDController.text;

          discountDetail = [
            {
              'detailid': detailid,
              'discountid': data['discountid'],
              'customerinfo': [
                {'id': id, 'fullname': fullname}
              ],
              'amount': discount,
            }
          ];

          addItem(data['discountid'], 'Discount ($type)', discount, 1, 1);

          discountItemCounter += 1;
        }
      }
    });
  }

  Future<void> _getdiscount() async {
    final results = await DiscountAPI().getDiscount();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        discountList.add(data['name']);
      }
    });
  }

  Future<void> _getpayment() async {
    final results = await PaymentAPI().getPayment();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        paymentList.add(data['paymentname']);
      }
    });
  }

  Future<void> _getemployees() async {
    final results = await EmployeesAPI().getEmployees();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        employees.add(data['fullname']);
      }
    });
  }

// #endregion
// #region Payment methods
  String formatAsCurrency(double value) {
    return toCurrencyString(value.toString());
  }

  Future<void> confirmAndRemove(int index) async {
    bool shouldRemove = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: const Text(
              'Are you sure you want to remove this item from the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel removal
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm removal
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      setState(() {
        itemsList.removeAt(index);
      });
    }
  }

  void updateQuantity(int index, int newQuantity) {
    print('entry: $newQuantity stocks: ${itemsList[index]['stocks']}');

    if (newQuantity < 1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Quantity'),
            content: const Text(
                'Setting the quantity to 0 or below will remove the item from the list. Continue?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  confirmAndRemove(index); // Show remove confirmation
                },
                child: const Text('Remove'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        if (newQuantity <= itemsList[index]['stocks']) {
          print('true');
          itemsList[index]['quantity'] = newQuantity;
        } else {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Alert'),
                  content:
                      Text('Stocks available ${itemsList[index]['stocks']}'),
                  icon: const Icon(Icons.warning),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                );
              });
        }
      });
    }
  }

  double calculateGrandTotal() {
    double grandTotal = 0;
    for (var product in itemsList) {
      grandTotal += product['price'] * product['quantity'];
    }
    return grandTotal;
  }

  double cashAmount = 0;

  void addItem(id, name, price, quantity, stocks) {
    setState(() {
      int existingIndex = itemsList.indexWhere((item) => item['name'] == name);

      if (stocks == 0) {
        print(stocks);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: const Text('Alert'),
                content: Text('Stocks available $stocks'),
                icon: const Icon(Icons.warning),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      } else {
        if (existingIndex != -1) {
          setState(() {
            int newQuantity = itemsList[existingIndex]['quantity'] + quantity;
            if (newQuantity > stocks) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Alert'),
                      content: Text('Stocks available $stocks'),
                      icon: const Icon(Icons.warning),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  });
            } else {
              itemsList[existingIndex]['quantity'] = newQuantity;
            }
          });
        } else {
          setState(() {
            itemsList.add({
              'id': id,
              'name': name,
              'price': price,
              'quantity': quantity,
              'stocks': stocks
            });
          });
        }
      }
    });
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      constraints: BoxConstraints.expand(width: double.infinity),
      builder: (BuildContext context) {
        return SearchModal(
          allItems: productList,
          addItem: addItem,
        );
      },
    );
  }

  void _showcategoryitems(BuildContext context, category) async {
    if (isStartShift != false) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Shift'),
              content: const Text(
                  'Shift not yet started. Go to OTHERS >> START SHIFT to start shift'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoadingSpinner(
              message: 'Loading',
            );
          });

      await _getcategoryitems(category)
          .then((value) => Navigator.of(context).pop());

      _showSearchModal();
    }
  }

  void others() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Others'),
            content: SingleChildScrollView(
              child: Center(
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(120, 90)),
                      onPressed: isStartShift
                          ? () {
                              _startShift(context, posid);
                            }
                          : null,
                      child: const Text(
                        'START\nSHIFT',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(120, 90)),
                      onPressed: isEndShift
                          ? () {
                              _endShift(context, posid);
                            }
                          : null,
                      child: const Text(
                        'END\nSHIFT',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(120, 90)),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Re-printing'),
                                content: SizedBox(
                                  height: 70,
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: _receiptORController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'OR Number',
                                            hintText: '200000001'),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      String receiptOR =
                                          _receiptORController.text.trim();
                                      Navigator.of(context).pop();
                                      _getdetails(context, receiptOR);
                                    },
                                    child: const Text('Print'),
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
                      child: const Text(
                        'RE-PRINT',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(120, 90)),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('REFUND'),
                                content: SizedBox(
                                  height: 400,
                                  width: 90,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: _refundORController,
                                        keyboardType: TextInputType.multiline,
                                        decoration: const InputDecoration(
                                            labelText: 'OR Number',
                                            hintText: '200000001'),
                                      ),
                                      TextField(
                                        controller: _refundReasonController,
                                        keyboardType: TextInputType.multiline,
                                        maxLength: 300,
                                        decoration: const InputDecoration(
                                            labelText: 'Reason',
                                            hintText:
                                                'Please enter reason of refund'),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      // String receiptOR =
                                      //     _receiptORController.text.trim();
                                      // Navigator.of(context).pop();
                                      // _getdetails(context, receiptOR);

                                      _refund();
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
                      child: const Text(
                        'REFUND',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(120, 90)),
                      onPressed: () {
                        final TextEditingController emailController =
                            TextEditingController();
                        final TextEditingController ornumberController =
                            TextEditingController();

                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Customer Email'),
                                content: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            labelText: 'Customer Email',
                                            hintText: 'you@example.com'),
                                      ),
                                      TextField(
                                        controller: ornumberController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'OR Number',
                                            hintText: '200000001'),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        String email = emailController.text;
                                        String ornumber =
                                            ornumberController.text;
                                        if (isValidEmail(email)) {
                                          String message = '';

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return LoadingSpinner(
                                                  message: 'Sending...',
                                                );
                                              });
                                          message = await _sendreceipt(
                                              email, ornumber);

                                          Navigator.of(context).pop();

                                          _clearItems();

                                          if (message != 'success') {
                                          } else {
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text('Success'),
                                                    content: const Text(
                                                        'E-Receipt sent successfully!'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('Ok'))
                                                    ],
                                                  );
                                                });
                                          }
                                        } else {
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Invalid'),
                                                  content: const Text(
                                                      'Invalid Email Address!'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Close'))
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                      child: const Text('Send')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close')),
                                ],
                              );
                            });
                      },
                      child: const Text(
                        'SEND\nE-RECEIPT',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(120, 90)),
                      onPressed: () {
                        // Navigator.pushReplacementNamed(context, '/setting');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                    employeeid: widget.employeeid,
                                    fullname: widget.fullname,
                                    accesstype: widget.accesstype,
                                    positiontype: widget.positiontype,
                                    logo: widget.logo,
                                  )),
                        );
                      },
                      child: const Text(
                        'SETTINGS',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                ]),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'))
            ],
          );
        });
  }

  void services() async {
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return LoadingSpinner(
    //         message: 'Loading',
    //       );
    //     });

    await ServicesAPI().getServices('ACTIVE').then((result) {
      if (result['msg'] == 'success') {
        setState(() {
          serviceList.clear();
          // productList =
          //     jsonData.map((data) => ProductPriceModel.fromJson(data)).toList();

          for (var data in result['data']) {
            serviceList.add(ServiceModel(
                data['id'],
                data['name'],
                data['price'],
                data['status'],
                data['createdby'],
                data['createddate']));
          }
        });

        final List<Widget> serviceitems = List<Widget>.generate(
            serviceList.length,
            (index) => SizedBox(
                  height: 70,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your button press logic here
                      // _showcategoryitems(
                      //     context, serviceList[index].categorycode);

                      addItem(
                          serviceList[index].id,
                          serviceList[index].name,
                          double.parse(serviceList[index].price.toString()),
                          1,
                          999);
                    },
                    child: Text(
                      serviceList[index].name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ));

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Services'),
                content: SingleChildScrollView(
                  child: Center(
                    child:
                        Wrap(spacing: 8, runSpacing: 8, children: serviceitems),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'))
                ],
              );
            });
      }
    });
  }

  void addons() async {
    await AddonAPI().getAddons('ACTIVE').then((result) {
      if (result['msg'] == 'success') {
        setState(() {
          addonList.clear();
          // productList =
          //     jsonData.map((data) => ProductPriceModel.fromJson(data)).toList();

          for (var data in result['data']) {
            addonList.add(AddonModel(
                data['id'],
                data['name'],
                data['type'],
                data['price'],
                data['status'],
                data['createdby'],
                data['createddate']));
          }
        });

        final List<Widget> serviceitems = List<Widget>.generate(
            addonList.length,
            (index) => SizedBox(
                  height: 70,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your button press logic here
                      // _showcategoryitems(
                      //     context, addonList[index].categorycode);

                      addItem(
                          addonList[index].id,
                          (addonList[index].type == 'SERVICE')
                              ? '${addonList[index].name} (Service)'
                              : '${addonList[index].name} (Product)',
                          double.parse(addonList[index].price.toString()),
                          1,
                          999);
                    },
                    child: Text(
                      addonList[index].name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ));

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('ADD ONS'),
                content: SingleChildScrollView(
                  child: Center(
                    child:
                        Wrap(spacing: 8, runSpacing: 8, children: serviceitems),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'))
                ],
              );
            });
      }
    });
  }

  void package() async {
    await PackageAPI().getPackage('ACTIVE').then((result) {
      if (result['msg'] == 'success') {
        setState(() {
          packageList.clear();
          // productList =
          //     jsonData.map((data) => ProductPriceModel.fromJson(data)).toList();

          for (var data in result['data']) {
            packageList.add(ServicePackageModel(
                data['id'],
                data['name'],
                data['details'],
                data['price'],
                data['status'],
                data['createdby'],
                data['createddate']));
          }
        });

        final List<Widget> packageitems = List<Widget>.generate(
            packageList.length,
            (index) => SizedBox(
                  height: 70,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your button press logic here
                      // _showcategoryitems(
                      //     context, packageList[index].categorycode);

                      addItem(
                          packageList[index].id,
                          packageList[index].name,
                          double.parse(packageList[index].price.toString()),
                          1,
                          999);
                    },
                    child: Text(
                      packageList[index].name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ));

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Package'),
                content: SingleChildScrollView(
                  child: Center(
                    child:
                        Wrap(spacing: 8, runSpacing: 8, children: packageitems),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'))
                ],
              );
            });
      }
    });
  }

  bool isValidEmail(String email) {
    String emailRegex = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(emailRegex);

    return regex.hasMatch(email);
  }

  Future<void> _transaction(
    String detailid,
    String posid,
    String date,
    String shift,
    String paymenttype,
    String items,
    String total,
    String cashier,
    String referenceid,
    String paymentname,
  ) async {
    try {
      final TextEditingController emailController = TextEditingController();
      final result = await POSTransaction().sending(
          detailid,
          date,
          posid,
          shift,
          paymenttype,
          referenceid,
          paymentname,
          items,
          total,
          salesrepresentative == '' ? widget.fullname : salesrepresentative,
          cashAmount.toString(),
          '0',
          branchid,
          jsonEncode(discountDetail));
      final pdfBytes = await Receipt(
              itemsList,
              cashAmount,
              detailid,
              posid,
              cashier,
              shift,
              companyname,
              address,
              tin,
              paymenttype,
              referenceid,
              paymentname,
              0,
              salesrepresentative == '' ? cashier : salesrepresentative)
          .printReceipt();
      Map<String, dynamic> printerconfig = {};
      Map<String, dynamic> emailconfig = {};
      if (Platform.isWindows) {
        printerconfig = await Helper().readJsonToFile('printer.json');
        emailconfig = await Helper().readJsonToFile('email.json');
      }

      if (Platform.isAndroid) {
        printerconfig = await Helper().JsonToFileRead('printer.json');
        emailconfig = await Helper().JsonToFileRead('email.json');
      }

      if (result['msg'] == 'success') {
        if (Platform.isAndroid && printerconfig['printerip'] == '') {
          Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async => pdfBytes,
              name: detailid.toString());
        } else if (Platform.isWindows) {
          List<Printer> printerList = await Printing.listPrinters();
          for (var localprinter in printerList) {
            if (localprinter.isDefault) {
              Printing.directPrintPdf(
                  printer: localprinter,
                  onLayout: (PdfPageFormat format) => pdfBytes);
            }
          }
        }

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Transaction successfull'),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _clearItems();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ReceiptScreen(
                      //       cash: cashAmount,
                      //       items: itemsList,
                      //       cashier: cashier,
                      //       detailid: detailid,
                      //       posid: posid,
                      //       shift: shift,
                      //     ),
                      //   ),
                      // );
                    },
                    child: const Text('OK'),
                  ),
                  if (printerconfig['productionprinterip'] != '')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary),
                      onPressed: () async {
                        await OrderSlip(itemsList,
                                Helper().GetCurrentDatetime(), detailid)
                            .printOrderSlip();
                      },
                      child: const Text('Printer Order Slip'),
                    ),
                  if (emailconfig['emailaddress'] != '')
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary),
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Customer Email'),
                                  content: SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextField(
                                          controller: emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                              labelText: 'Customer Email',
                                              hintText: 'you@example.com'),
                                        )
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          String email = emailController.text;
                                          if (isValidEmail(email)) {
                                            String message = '';

                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return LoadingSpinner(
                                                    message: 'Sending...',
                                                  );
                                                });
                                            message = await Email().sendMail(
                                                detailid.toString(),
                                                email,
                                                pdfBytes,
                                                cashier,
                                                itemsList,
                                                paymentname,
                                                referenceid);

                                            Navigator.of(context).pop();

                                            if (message != 'success') {
                                            } else {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text('Success'),
                                                      content: const Text(
                                                          'E-Receipt sent successfully!'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Ok'))
                                                      ],
                                                    );
                                                  });

                                              _clearItems();
                                            }
                                          } else {
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text('Invalid'),
                                                    content: const Text(
                                                        'Invalid Email Address!'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              'Close'))
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                        child: const Text('Send')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Close')),
                                  ],
                                );
                              });
                        },
                        child: const Text('Send E-Receipt')),
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(
                    'Please inform administrator. Thank you! ${result['status']}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      }
    } catch (e) {
      print(e);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Transaction Error'),
              content: Text('Please inform administrator. Thank you! $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
  }

  void _clearItems() {
    setState(() {
      productList.clear();
      itemsList.clear();
      discountDetail.clear();
      _referenceidController.clear();
      _splitReferenceidController.clear();
      _splitCashController.clear();
      _splitAmountController.clear();
      _discountFullnameController.clear();
      _discountIDController.clear();

      discountItemCounter = 0;

      shiftsolditems.clear();
      shiftstaffsales.clear();
      shiftsummarypayment.clear();
    });
  }

  double _remaining() {
    double total = calculateGrandTotal();

    setState(() {
      remaining = total - (splitcash + splitepayamount);
    });

    return remaining;
  }

  Future<void> _splitpayment(
      double cashamount,
      double epayamount,
      String paymentmethod,
      String referenceid,
      String epaymentname,
      String detailid,
      String cashier,
      String items) async {
    final TextEditingController emailController = TextEditingController();
    double total = cashamount + epayamount;
    final result = await POSTransaction().sending(
        detailid,
        helper.GetCurrentDatetime(),
        posid,
        shift,
        paymentmethod,
        referenceid,
        epaymentname,
        items,
        total.toString(),
        cashier,
        cashamount.toString(),
        epayamount.toString(),
        branchid,
        jsonEncode(discountDetail));

    final pdfBytes = await Receipt(
            itemsList,
            cashamount,
            detailid,
            posid,
            widget.fullname,
            shift,
            companyname,
            address,
            tin,
            paymentmethod,
            referenceid,
            epaymentname,
            epayamount,
            salesrepresentative == '' ? widget.fullname : salesrepresentative)
        .printReceipt();

    Map<String, dynamic> printerconfig = {};
    Map<String, dynamic> emailconfig = {};
    if (Platform.isWindows) {
      printerconfig = await Helper().readJsonToFile('printer.json');
      emailconfig = await Helper().readJsonToFile('email.json');
    }

    if (Platform.isAndroid) {
      printerconfig = await Helper().JsonToFileRead('printer.json');
      emailconfig = await Helper().JsonToFileRead('email.json');
    }

    if (result['msg'] == 'success') {
      Navigator.of(context);
      if (Platform.isAndroid) {
        // Printing.layoutPdf(
        //   onLayout: (PdfPageFormat format) => pdfBytes,
        // );

        // Printing.directPrintPdf(
        //     printer: const Printer(url: ''),
        //     onLayout: (PdfPageFormat format) => pdfBytes);
      } else if (Platform.isWindows) {
        List<Printer> printerList = await Printing.listPrinters();
        for (var printer in printerList) {
          if (printer.isDefault) {
            Printing.directPrintPdf(
                printer: printer, onLayout: (PdfPageFormat format) => pdfBytes);
          }
        }
      }

      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Transaction process successfully!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _clearItems();
                  },
                  child: const Text('OK'),
                ),
                if (printerconfig['productionprinterip'] != '')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary),
                    onPressed: () async {
                      await OrderSlip(itemsList, Helper().GetCurrentDatetime(),
                              detailid)
                          .printOrderSlip();
                    },
                    child: const Text('Printer Order Slip'),
                  ),
                if (emailconfig['emailaddress'] != '')
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Customer Email'),
                                content: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            labelText: 'Customer Email',
                                            hintText: 'you@example.com'),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        String email = emailController.text;
                                        if (isValidEmail(email)) {
                                          String message = '';

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return LoadingSpinner(
                                                  message: 'Sending...',
                                                );
                                              });
                                          message = await Email().sendMail(
                                              detailid.toString(),
                                              email,
                                              pdfBytes,
                                              cashier,
                                              itemsList,
                                              epaymentname,
                                              referenceid);

                                          Navigator.of(context).pop();

                                          if (message != 'success') {
                                          } else {
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text('Success'),
                                                    content: const Text(
                                                        'E-Receipt sent successfully!'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('Ok'))
                                                    ],
                                                  );
                                                });

                                            _clearItems();
                                          }
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Invalid'),
                                                  content: const Text(
                                                      'Invalid Email Address!'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Close'))
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                      child: const Text('Send')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close')),
                                ],
                              );
                            });
                      },
                      child: const Text('Send E-Receipt')),
              ],
            );
          });
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(
                  'Please inform administrator. Thank you! ${result['status']}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
  }

  Future<void> _discount() async {
    final List<Widget> discount = List<Widget>.generate(
        discountList.length,
        (index) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary),
              onPressed: () {
                if (discountItemCounter == 1) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Warning'),
                          content: const Text(
                              'This POS is only accepts one discount'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        );
                      });
                } else {
                  (discountList[index] == 'PWD' ||
                          discountList[index] == 'Senior')
                      ? showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(discountList[index]),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: _discountIDController,
                                      decoration: const InputDecoration(
                                        labelText: 'ID',
                                        hintText: '163456',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: _discountFullnameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Fullname',
                                        hintText: 'Juan Dela Cruz',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _getdiscountrate(discountList[index]);
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Apply'),
                                ),
                              ],
                            );
                          })
                      : _getdiscountrate(discountList[index]);
                }
              },
              child: Text(
                discountList[index],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ));

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Discounts'),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: discount,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

  Future<void> _epayment() async {
    final List<Widget> epayments = List<Widget>.generate(
        paymentList.length,
        (index) => SizedBox(
              height: 70,
              width: 120,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                'Total: ${formatAsCurrency(calculateGrandTotal())}'),
                            content: SizedBox(
                              height: 300,
                              width: 300,
                              child: Column(children: [
                                TextField(
                                  controller: _referenceidController,
                                  decoration: InputDecoration(
                                      labelText:
                                          '${paymentList[index]} Reference ID'),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    CurrencyInputFormatter(
                                      leadingSymbol: CurrencySymbols.PESO,
                                    ),
                                  ],
                                  onChanged: (value) {
                                    // Remove currency symbols and commas to get the numeric value
                                    String numericValue = value.replaceAll(
                                      RegExp('[${CurrencySymbols.PESO},]'),
                                      '',
                                    );
                                    setState(() {
                                      cashAmount =
                                          double.tryParse(numericValue) ?? 0;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Enter amount',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ]),
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('close')),
                              ElevatedButton(
                                onPressed: () {
                                  String paymenttype = 'EPAYMENT';
                                  String paymentname = paymentList[index];
                                  String message = '';
                                  String title = '';
                                  String referenceid =
                                      _referenceidController.text;

                                  if (cashAmount == 0) {
                                    message +=
                                        'Please enter amount to proceed.\n';
                                    title += '[Enter Amount]';
                                  }
                                  if (cashAmount < calculateGrandTotal()) {
                                    message +=
                                        'Please enter the right amount received from $paymentname your total due is ${calculateGrandTotal()}.\n';
                                    title += '[Insufficient Funds]';
                                  }
                                  if (cashAmount > calculateGrandTotal()) {
                                    message +=
                                        'Please enter the exact amount do not over your total due is ${calculateGrandTotal()}.\n';
                                    title += '[Overfunded]';
                                  }

                                  if (referenceid == '') {
                                    message +=
                                        'Please enter the reference ID.\n';
                                    title += '[No Referenceid]';
                                  }

                                  if (message != '') {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(title),
                                            content: Text(message),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    detailid++;
                                    _transaction(
                                        detailid.toString(),
                                        posid,
                                        helper.GetCurrentDatetime(),
                                        shift,
                                        paymenttype,
                                        jsonEncode(itemsList),
                                        calculateGrandTotal().toString(),
                                        widget.fullname,
                                        referenceid,
                                        paymentname);

                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Proceed'),
                              ),
                            ],
                          );
                        });
                  },
                  child: Text(
                    paymentList[index],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )),
            ));

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select E-Payment Type'),
            content: Container(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: epayments,
              ),
            ),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

  Future<void> _refund() async {
    String reason = _refundReasonController.text;
    String ornumber = _refundORController.text;
    final results =
        await SalesDetails().refund(ornumber, reason, widget.fullname);
    final jsonData = json.encode(results['data']);

    print(results);

    if (jsonData.length == 2) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Not Found'),
              content: Text('OR Number $ornumber not found'),
              icon: const Icon(Icons.warning),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    } else {
      if (results['msg'] == 'refunded') {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Already Exist'),
                content: Text('OR Number $ornumber already refunded!'),
                icon: const Icon(Icons.warning),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      }

      if (results['msg'] == 'ornotexist') {
        return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Not Exist'),
                content: Text('OR Number $ornumber does not exist!'),
                icon: const Icon(Icons.warning),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      }

      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: Text('OR Number $ornumber successfully refunded!'),
              icon: const Icon(Icons.check),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
  }

// #endregion
  @override
  Widget build(BuildContext context) {
    final List<Widget> category = List<Widget>.generate(
        categoryList.length,
        (index) => SizedBox(
              height: 70,
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary),
                onPressed: () {
                  // Add your button press logic here
                  _showcategoryitems(context, categoryList[index].categorycode);
                },
                child: Text(
                  categoryList[index].categoryname,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ));

    List<String> options = ['Select Payment Type', 'GCASH', 'PAYMAYA', 'CARD'];
    String splitEPaymentType = options[1];
    String selectedSalesRepresentative = '';

    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        leading: Container(
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          child: ClipOval(
            child: SvgPicture.string(branchlogo),
          ),
        ),
        title: Text(
          companyname,
          style: const TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          Row(
            children: [
              TextButton.icon(
                icon: Icon(Icons.clear_all),
                onPressed: () => _clearItems(),
                label: Text('Clear Items'),
                style: ButtonStyle(
                    foregroundColor:
                        WidgetStateProperty.all<Color>(Colors.white)),
              ),
              SizedBox(
                width: 60,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                color: Colors.white,
                onPressed: () {
                  // Add your logout logic here

                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Logut'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // if (Platform.isAndroid) {

                                // }

                                Navigator.pushReplacementNamed(context, '/');
                              },
                              child: const Text('OK'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 270,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 67, 67, 67),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 1,
                    columns: const [
                      DataColumn(
                          label: Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                      DataColumn(
                          label: Text(
                        'Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                      DataColumn(
                          label: Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                      DataColumn(
                          label: Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                      DataColumn(label: Text('')),
                    ],
                    rows: itemsList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> product = entry.value;
                      double totalCost = product['price'] * product['quantity'];
                      return DataRow(cells: [
                        DataCell(Text(
                          product['name'],
                          textAlign: TextAlign.left,
                        )),
                        DataCell(
                          Text(formatAsCurrency(product['price'])),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                color: const Color.fromARGB(255, 213, 86, 86),
                                onPressed: () {
                                  if (product['quantity'] > 0) {
                                    updateQuantity(
                                        index, product['quantity'] - 1);
                                  }

                                  print(product['name']);

                                  if (product['name']
                                      .toString()
                                      .contains('Discount')) {
                                    discountItemCounter -= 1;
                                  }
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(fontSize: 16),
                                  keyboardType: TextInputType.number,
                                  onChanged: (newQuantity) {
                                    int parsedQuantity =
                                        int.tryParse(newQuantity) ?? 0;
                                    updateQuantity(index, parsedQuantity);
                                  },
                                  controller: TextEditingController(
                                      text: product['quantity'].toString()),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                color: const Color.fromARGB(255, 92, 213, 86),
                                onPressed: () {
                                  updateQuantity(
                                      index, product['quantity'] + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(formatAsCurrency(totalCost))),
                        DataCell(IconButton(
                            onPressed: () {
                              confirmAndRemove(index);
                            },
                            icon: const Icon(Icons.delete))),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Shift:  $shift',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'OR:  $detailid',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        'Total :  ${formatAsCurrency(calculateGrandTotal())}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5), //DIVIDER START
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _serialNumberController,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 2, 90, 71)),
                          ),
                          labelText: 'Serial Number',
                          labelStyle:
                              TextStyle(color: Color.fromARGB(255, 2, 90, 71)),
                          border: OutlineInputBorder(),
                          hintText: 'Enter Serial',
                          prefixIcon: Icon(Icons.qr_code_2_outlined),
                        ),
                        textInputAction: TextInputAction.go,
                        onEditingComplete: () {
                          _search();
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Enter pressed!'),
                          //   ),
                          // );
                          _serialNumberController.clear();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            minimumSize: const Size(80, 60)),
                        onPressed: () {
                          _search();
                        },
                        child: const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5), //DIVIDER START
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _discount();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(120, 70)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.tag,
                              size: 16), // Adjust size as needed
                        ),
                        const Text('DISCOUNT'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print(itemsList.length);
                      }
                      if (itemsList.isEmpty) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Empty Transaction'),
                                content: const Text(
                                    'Your transaction list is empty. Please add items before proceeding to payment.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              // alignment: Alignment.center,
                              title: const Text(
                                'PAYMENT METHOD',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: DropdownMenu(
                                        width: 460,
                                        initialSelection: employees.first,
                                        onSelected: (String? value) {
                                          selectedSalesRepresentative = value!;
                                          setState(() {
                                            salesrepresentative =
                                                selectedSalesRepresentative;
                                          });
                                        },
                                        dropdownMenuEntries: employees
                                            .map<DropdownMenuEntry<String>>(
                                                (String value) {
                                          return DropdownMenuEntry<String>(
                                              value: value, label: value);
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _epayment();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                      child: const Text('E-PAYMENT'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Cash Payment'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      'Please collect cash from the customer. Total: ${formatAsCurrency(calculateGrandTotal())}'),
                                                  const SizedBox(
                                                    height: 16,
                                                  ), // Add spacing between text and text field

                                                  TextField(
                                                    controller:
                                                        _cashReceivedController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      CurrencyInputFormatter(
                                                        leadingSymbol:
                                                            CurrencySymbols
                                                                .PESO,
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      // Remove currency symbols and commas to get the numeric value
                                                      String numericValue =
                                                          value.replaceAll(
                                                        RegExp(
                                                            '[${CurrencySymbols.PESO},]'),
                                                        '',
                                                      );
                                                      setState(() {
                                                        cashAmount =
                                                            double.tryParse(
                                                                    numericValue) ??
                                                                0;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: 'Enter amount',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ////ARECEIPT
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          foregroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onPrimary),
                                                  onPressed: () {
                                                    String message = '';
                                                    String title = '';

                                                    if (_cashReceivedController
                                                            .text ==
                                                        '') {
                                                      cashAmount =
                                                          calculateGrandTotal();
                                                    }

                                                    if (cashAmount == 0) {
                                                      message +=
                                                          'Please enter cash tendered to proceed.';
                                                      title += '[Enter Amount]';
                                                    }
                                                    if (cashAmount <
                                                        calculateGrandTotal()) {
                                                      message +=
                                                          'Please enter the right amount of cash.';
                                                      title +=
                                                          '[Insufficient Funds]';
                                                    }

                                                    if (message != '') {
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title:
                                                                  Text(title),
                                                              content:
                                                                  Text(message),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Close the dialog
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          'OK'),
                                                                ),
                                                              ],
                                                            );
                                                          });
                                                    } else {
                                                      detailid++;
                                                      _transaction(
                                                          detailid.toString(),
                                                          posid,
                                                          helper
                                                              .GetCurrentDatetime(),
                                                          shift,
                                                          'CASH',
                                                          jsonEncode(itemsList),
                                                          calculateGrandTotal()
                                                              .toString(),
                                                          widget.fullname,
                                                          'CASH',
                                                          'CASH');

                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                  child: const Text('Proceed'),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Close'))
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary),
                                      child: const Text('CASH'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 60,
                                    width: 120,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _remaining();

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Split Payment'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          'Please collect cash from the customer. Total: ${formatAsCurrency(calculateGrandTotal())}'),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          CurrencyInputFormatter(
                                                            leadingSymbol:
                                                                CurrencySymbols
                                                                    .PESO,
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          String numericValue =
                                                              value.replaceAll(
                                                            RegExp(
                                                                '[${CurrencySymbols.PESO},]'),
                                                            '',
                                                          );

                                                          setState(() {
                                                            splitcash =
                                                                double.tryParse(
                                                                        numericValue) ??
                                                                    0;

                                                            _remaining();
                                                          });
                                                        },
                                                        controller:
                                                            _splitCashController,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Enter amount',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 90,
                                                      ),
                                                      DropdownMenu(
                                                        initialSelection:
                                                            paymentList.first,
                                                        onSelected:
                                                            (String? value) {
                                                          setState(() {
                                                            splitEPaymentType =
                                                                value!;
                                                          });
                                                        },
                                                        dropdownMenuEntries:
                                                            paymentList.map<
                                                                DropdownMenuEntry<
                                                                    String>>((String
                                                                value) {
                                                          return DropdownMenuEntry<
                                                                  String>(
                                                              value: value,
                                                              label: value);
                                                        }).toList(),
                                                      ),
                                                      TextField(
                                                        controller:
                                                            _splitReferenceidController,
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    'Reference ID'),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextField(
                                                        controller:
                                                            _splitAmountController,
                                                        inputFormatters: [
                                                          CurrencyInputFormatter(
                                                            leadingSymbol:
                                                                CurrencySymbols
                                                                    .PESO,
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          String numericValue =
                                                              value.replaceAll(
                                                            RegExp(
                                                                '[${CurrencySymbols.PESO},]'),
                                                            '',
                                                          );

                                                          setState(() {
                                                            splitepayamount =
                                                                double.tryParse(
                                                                        numericValue) ??
                                                                    0;

                                                            _remaining();
                                                          });
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Enter amount',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          String
                                                              splitReferenceid =
                                                              _splitReferenceidController
                                                                  .text;

                                                          double totaltendered =
                                                              splitcash +
                                                                  splitepayamount;

                                                          String message = '';
                                                          String title = '';

                                                          if (totaltendered ==
                                                              0) {
                                                            message +=
                                                                'Please enter amount to proceed.\n';
                                                            title +=
                                                                '[Enter Amount]';
                                                          }
                                                          if (totaltendered <
                                                              calculateGrandTotal()) {
                                                            message +=
                                                                'Please enter the right amount received from e-payment or cash.\n';
                                                            title +=
                                                                '[Insufficient Funds]';
                                                          }
                                                          if (splitReferenceid ==
                                                              '') {
                                                            message +=
                                                                'Please enter reference id.\n';
                                                            title +=
                                                                '[Reference ID]';
                                                          }

                                                          if (totaltendered >
                                                              calculateGrandTotal()) {
                                                            message +=
                                                                'Please enter the right amount received from e-payment or cash.\n';
                                                            title +=
                                                                '[Overfunds]';
                                                          }

                                                          if (remaining > 0) {
                                                            message +=
                                                                'Remaining: $remaining\n';
                                                            title +=
                                                                '[Remaining Balance]';
                                                          }

                                                          if (splitEPaymentType ==
                                                              'Select Payment Type') {
                                                            message +=
                                                                'Please select payment type\n';
                                                            title +=
                                                                '[Payment Type]';
                                                          }

                                                          if (message != '') {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        title),
                                                                    content: Text(
                                                                        message),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text('Close'))
                                                                    ],
                                                                  );
                                                                });
                                                          } else {
                                                            detailid++;

                                                            _splitpayment(
                                                              splitcash,
                                                              splitepayamount,
                                                              'SPLIT',
                                                              splitReferenceid,
                                                              splitEPaymentType,
                                                              detailid
                                                                  .toString(),
                                                              salesrepresentative ==
                                                                      ''
                                                                  ? widget
                                                                      .fullname
                                                                  : salesrepresentative,
                                                              jsonEncode(
                                                                  itemsList),
                                                            );

                                                            Navigator.pop(
                                                                context);

                                                            Navigator.pop(
                                                                context);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Submit')),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                        child:
                                                            const Text('Close'))
                                                  ],
                                                );
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary),
                                        child: const Text('SPLIT')),
                                  )
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(120, 70)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.moneyBill,
                              size: 16), // Adjust size as needed
                        ),
                        const Text('PAYMENT'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      others();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(120, 70)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.gears,
                              size: 16), // Adjust size as needed
                        ),
                        const Text('OTHERS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 5,
            ), //END
            const Center(
              child: Text('Product Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            Wrap(
                spacing: 8, // Adjust the spacing between buttons
                runSpacing: 8, // Adjust the vertical spacing between rows
                children: category),

            const SizedBox(
              height: 5,
            ), //DIVIDER START
            const Center(
              child: Text('Services & Add-ons',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (isStartShift != false) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Shift'),
                                content: const Text(
                                    'Shift not yet started. Go to OTHERS >> START SHIFT to start shift'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      } else {
                        services();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(120, 70)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.handHolding,
                              size: 16), // Adjust size as needed
                        ),
                        const Text('SERVICES'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isStartShift != false) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Shift'),
                                content: const Text(
                                    'Shift not yet started. Go to OTHERS >> START SHIFT to start shift'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      } else {
                        package();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(120, 70)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.boxesStacked,
                              size: 16), // Adjust size as needed
                        ),
                        const Text('PACKAGE'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isStartShift != false) {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Shift'),
                                content: const Text(
                                    'Shift not yet started. Go to OTHERS >> START SHIFT to start shift'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      } else {
                        addons();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(120, 70)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.boxTissue,
                              size: 16), // Adjust size as needed
                        ),
                        const Text('ADD-ONS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchModal extends StatefulWidget {
  final List<ProductPriceModel> allItems;
  final Function addItem;

  const SearchModal({super.key, required this.allItems, required this.addItem});

  @override
  _SearchModalState createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  late List<ProductPriceModel> _filteredItems;

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.allItems;
  }

  void _filterItems(String searchText) {
    setState(() {
      _searchText = searchText;
      if (_searchText.isEmpty) {
        _filteredItems = widget.allItems;
      } else {
        _filteredItems = widget.allItems
            .where((item) => item.description
                .toLowerCase()
                .contains(_searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> categoryitems = List<Widget>.generate(
        _filteredItems.length,
        (index) => ElevatedButton.icon(
              icon: Image.memory(
                  height: 120,
                  width: 120,
                  base64Decode(_filteredItems[index].productimage)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                fixedSize: Size(320, 120),
              ),
              onPressed: (_filteredItems[index].quantity <= 0)
                  ? null
                  : () {
                      widget.addItem(
                          _filteredItems[index].productid,
                          _filteredItems[index].description,
                          double.parse(_filteredItems[index].price),
                          1,
                          _filteredItems[index].quantity);
                    },
              label: Text(
                '${_filteredItems[index].description}\nStocks:${_filteredItems[index].quantity}\n\nSKU:${_filteredItems[index].barcode}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ));

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterItems,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: categoryitems,
          ),
        ],
      ),
    );

    // return DraggableScrollableSheet(
    //   expand: false,
    //   builder: (BuildContext context, ScrollController scrollController) {
    //     return Column(
    //       mainAxisSize: MainAxisSize.max,
    //       children: <Widget>[
    //         Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: TextField(
    //             onChanged: _filterItems,
    //             decoration: InputDecoration(
    //               labelText: 'Search',
    //               border: OutlineInputBorder(
    //                 borderRadius: BorderRadius.circular(8.0),
    //               ),
    //             ),
    //           ),
    //         ),
    //         Expanded(
    //           child: ListView.builder(
    //             controller: scrollController,
    //             itemCount: _filteredItems.length,
    //             itemBuilder: (context, index) {
    //               return Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: ListTile(
    //                   onTap: (_filteredItems[index].quantity <= 0)
    //                       ? null
    //                       : () => widget.addItem(
    //                           _filteredItems[index].productid,
    //                           _filteredItems[index].description,
    //                           double.parse(_filteredItems[index].price),
    //                           1,
    //                           _filteredItems[index].quantity),
    //                   title: Text(
    //                     _filteredItems[index].description,
    //                     style: const TextStyle(
    //                         fontSize: 24,
    //                         fontWeight: FontWeight.bold,
    //                         color: Colors.white),
    //                     textAlign: TextAlign.left,
    //                   ),
    //                   subtitle: Text(
    //                     'SKU: ${_filteredItems[index].barcode}',
    //                     style: const TextStyle(
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.normal,
    //                         color: Colors.white),
    //                     textAlign: TextAlign.left,
    //                   ),
    //                   leading: Image.memory(
    //                       base64Decode(_filteredItems[index].productimage)),
    //                   trailing: Text(
    //                     'Stocks: ${_filteredItems[index].quantity}',
    //                     style: const TextStyle(
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.bold,
    //                         color: Colors.white),
    //                     textAlign: TextAlign.center,
    //                   ),
    //                   tileColor: (_filteredItems[index].quantity <= 0)
    //                       ? Colors.grey
    //                       : Colors.teal.shade800,
    //                 ),
    //               );
    //             },
    //           ),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
