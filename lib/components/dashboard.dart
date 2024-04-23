import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:fiveLPOS/api/addon.dart';
import 'package:fiveLPOS/api/employees.dart';
import 'package:fiveLPOS/api/package.dart';
import 'package:fiveLPOS/api/services.dart';
import 'package:fiveLPOS/components/settings.dart';
import 'package:fiveLPOS/model/addon.dart';
import 'package:fiveLPOS/model/category.dart';
import 'package:fiveLPOS/model/servicepackage.dart';
import 'package:fiveLPOS/model/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:pdf/pdf.dart';
import 'package:fiveLPOS/api/discount.dart';
import 'package:fiveLPOS/api/payment.dart';
import 'package:fiveLPOS/api/posshiftlog.dart';
import 'package:fiveLPOS/components/loadingspinner.dart';
import 'package:fiveLPOS/model/productprice.dart';
import 'package:fiveLPOS/api/category.dart';
import 'package:fiveLPOS/repository/customerhelper.dart';
import 'package:fiveLPOS/api/salesdetails.dart';
import 'package:fiveLPOS/api/productprice.dart';
import 'package:fiveLPOS/repository/dbhelper.dart';
import 'package:fiveLPOS/repository/email.dart';
import 'package:fiveLPOS/repository/receipt.dart';
import 'package:fiveLPOS/api/transaction.dart';
import 'package:fiveLPOS/repository/reprint.dart';
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
  final NetworkPrinter printer;
  final String printerstatus;

  const MyDashboard(
      {super.key,
      required this.employeeid,
      required this.fullname,
      required this.accesstype,
      required this.positiontype,
      required this.logo,
      required this.printer,
      required this.printerstatus});

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
  List<Map<String, dynamic>> discountDetail = [];

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

  Helper helper = Helper();
  DatabaseHelper dbHelper = DatabaseHelper();
  int detailid = 100000000;

  String branchlogo = '';
  // String branchlogo = '';

  String salesrepresentative = '';
  List<String> employees = [];

  final TextEditingController _searchController = TextEditingController();
  List<ProductPriceModel> filteredList = [];

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
              ecash.toDouble(),
              widget.printer)
          .printReceipt();

      if (Platform.isWindows) {
        List<Printer> printerList = await Printing.listPrinters();
        for (var printer in printerList) {
          if (printer.isDefault) {
            Printing.directPrintPdf(
                printer: printer, onLayout: (PdfPageFormat format) => pdfBytes);
          }
        }
      }

      if (Platform.isAndroid) {
        // Printing.layoutPdf(
        //   onLayout: (PdfPageFormat format) async => pdfBytes,
        // );
      }
    }
  }

  Future<String> _semdreceipt(email, ornumber) async {
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
                ecash.toDouble(),
                widget.printer)
            .printReceipt();

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
    String description = '';
    double price = 0;
    double stocks = 0;

    print('Data Length: ${jsonData.length}');

    if (jsonData.length != 0) {
      setState(() {
        for (var data in jsonData) {
          print(data);
          description = data['description'];
          price = double.parse(data['price'].toString());
          stocks = double.parse(data['quantity'].toString());
          addItem(description, price, 1, stocks);
        }
      });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text(
                  'Item not found with SN:${_serialNumberController.text}'),
              icon: Icon(Icons.warning),
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
        double discount =
            ((calculateGrandTotal() * 1.12) * (data['rate'] / 100)) * -1;

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

          addItem('Discount ($type)', discount, 1, 1);

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
    return '${toCurrencyString(value.toString())}';
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

  void addItem(name, price, quantity, stocks) {
    setState(() {
      int existingIndex = itemsList.indexWhere((item) => item['name'] == name);

      if (stocks == 0) {
        print(stocks);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Alert'),
                content: Text('Stocks available $stocks'),
                icon: Icon(Icons.warning),
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
                      title: Text('Alert'),
                      content: Text('Stocks available $stocks'),
                      icon: Icon(Icons.warning),
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

  void filterList(String query) {
    filteredList = productList
        .where((item) =>
            item.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final List<Widget> product = List<Widget>.generate(
        filteredList.length,
        (index) => SizedBox(
              height: 80,
              width: 220,
              child: ElevatedButton(
                onPressed: (filteredList[index].quantity <= 0)
                    ? null
                    : () {
                        // Add your button press logic here
                        addItem(
                            filteredList[index].description,
                            double.parse(filteredList[index].price),
                            1,
                            filteredList[index].quantity);
                      },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.memory(
                        base64Decode(filteredList[index].productimage)),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${filteredList[index].description}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Stocks: ${filteredList[index].quantity}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ));

    // Update the bottom sheet content
    Navigator.of(context).pop();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    filterList(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Enter search keyword',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        // return AlertDialog(
        //   title: const Center(child: Text('Products')),
        //   content: SingleChildScrollView(
        //     child: Column(
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: TextField(
        //             controller: _searchController,
        //             onChanged: (value) {
        //               filterList(value);
        //             },
        //             autofocus: true,
        //             decoration: InputDecoration(
        //               labelText: 'Search',
        //               hintText: 'Enter search keyword',
        //               prefixIcon: Icon(Icons.search),
        //               border: OutlineInputBorder(),
        //             ),
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: product.isEmpty
        //               ? const Text('No Product Found')
        //               : Wrap(
        //                   spacing: 8, // Adjust the spacing between buttons
        //                   runSpacing:
        //                       8, // Adjust the vertical spacing between rows
        //                   children: product),
        //         ),
        //       ],
        //     ),
        //   ),
        //   actions: [
        //     TextButton(
        //       onPressed: () {
        //         Navigator.of(context).pop(); // Close the dialog
        //       },
        //       child: const Text('Close'),
        //     ),
        //   ],
        // );
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

      final List<Widget> product = List<Widget>.generate(
          productList.length,
          (index) => SizedBox(
                height: 80,
                width: 220,
                child: ElevatedButton(
                  onPressed: (productList[index].quantity <= 0)
                      ? null
                      : () {
                          // Add your button press logic here
                          addItem(
                              productList[index].description,
                              double.parse(productList[index].price),
                              1,
                              productList[index].quantity);
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.memory(
                          base64Decode(productList[index].productimage)),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${productList[index].description}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Stocks: ${productList[index].quantity}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ));

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      filterList(value);
                    },
                    decoration: InputDecoration(
                        labelText: 'Enter Product Name',
                        hintText: 'Alrik',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product,
                    ),
                  ),
                ),
              ],
            ),
          );

          // return AlertDialog(
          //   title: const Center(child: Text('Products')),
          //   content: SingleChildScrollView(
          //     child: Center(
          //       child: Column(
          //         children: [
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: TextField(
          //               controller: _searchController,
          //               onChanged: (value) {
          //                 filterList(value);
          //               },
          //               decoration: InputDecoration(
          //                 labelText: 'Search',
          //                 hintText: 'Enter search keyword',
          //                 prefixIcon: Icon(Icons.search),
          //                 border: OutlineInputBorder(),
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Wrap(
          //                 spacing: 8, // Adjust the spacing between buttons
          //                 runSpacing:
          //                     8, // Adjust the vertical spacing between rows
          //                 children: product),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          //   actions: [
          //     TextButton(
          //       onPressed: () {
          //         Navigator.of(context).pop(); // Close the dialog
          //       },
          //       child: const Text('Close'),
          //     ),
          //   ],
          // );
        },
      );
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
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
                      onPressed: isStartShift
                          ? () {
                              _startShift(context, posid);
                            }
                          : null,
                      child: const Text(
                        'START\nSHIFT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
                      onPressed: isEndShift
                          ? () {
                              _endShift(context, posid);
                            }
                          : null,
                      child: const Text(
                        'END\nSHIFT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Re-printing'),
                                content: SizedBox(
                                  height: 80,
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
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
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
                                          message = await _semdreceipt(
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
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
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
                                    printer: widget.printer,
                                  )),
                        );
                      },
                      child: const Text(
                        'SETTINGS',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
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
                  height: 80,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your button press logic here
                      // _showcategoryitems(
                      //     context, serviceList[index].categorycode);

                      addItem(
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
                  height: 80,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your button press logic here
                      // _showcategoryitems(
                      //     context, addonList[index].categorycode);

                      addItem(
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
                  height: 80,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your button press logic here
                      // _showcategoryitems(
                      //     context, packageList[index].categorycode);

                      addItem(
                          '${packageList[index].name}',
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
              widget.printer,
              salesrepresentative == '' ? cashier : salesrepresentative)
          .printReceipt();
      Map<String, dynamic> printerconfig = {};
      if (Platform.isWindows) {
        printerconfig = await Helper().readJsonToFile('printer.json');
      }

      if (Platform.isAndroid) {
        printerconfig = await Helper().JsonToFileRead('printer.json');
      }

      if (result['msg'] == 'success') {
        if (Platform.isAndroid) {
          if (printerconfig['isenable']) {
          } else {
            Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdfBytes,
                name: detailid.toString());
          }
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
                actions: [
                  TextButton(
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
                  TextButton(
                      onPressed: () {
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
            widget.printer,
            salesrepresentative == '' ? widget.fullname : salesrepresentative)
        .printReceipt();

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
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                                      keyboardType: TextInputType.emailAddress,
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
        (index) => SizedBox(
              height: 60,
              width: 120,
              child: ElevatedButton(
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
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
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
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _discountIDController,
                                        decoration: const InputDecoration(
                                          labelText: 'ID',
                                          hintText: '123456',
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
            title: const Text('Discounts'),
            content: Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
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
              height: 60,
              width: 120,
              child: ElevatedButton(
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
                                  String paymenttype = 'EPAYMENT';
                                  String paymentname = paymentList[index];
                                  String message = '';
                                  String title = '';

                                  if (cashAmount == 0) {
                                    message +=
                                        'Please enter amount to proceed.';
                                    title += '[Enter Amount]';
                                  }
                                  if (cashAmount < calculateGrandTotal()) {
                                    message +=
                                        'Please enter the right amount received from e-payment.';
                                    title += '[Insufficient Funds]';
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
                                    String referenceid =
                                        _referenceidController.text;
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
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Colors.brown, // Change the color here
                                  ),
                                  // Other button styles...
                                ),
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
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

// #endregion
  @override
  Widget build(BuildContext context) {
    final List<Widget> category = List<Widget>.generate(
        categoryList.length,
        (index) => SizedBox(
              height: 80,
              width: 120,
              child: ElevatedButton(
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

    List<String> options = ['Select Payment Type', 'Gcash', 'Paymaya', 'Card'];
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
        title: Text(companyname),
        actions: <Widget>[
          Row(
            children: [
              const Text('Logout'),
              IconButton(
                icon: const Icon(Icons.logout),
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
                height: 280,
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
                    columnSpacing: 20,
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
                      // DataColumn(label: Text('')),
                    ],
                    rows: itemsList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> product = entry.value;
                      double totalCost = product['price'] * product['quantity'];
                      return DataRow(cells: [
                        DataCell(SizedBox(
                            width: 120,
                            child: Text(
                              product['name'],
                              textAlign: TextAlign.left,
                            ))),
                        DataCell(
                          SizedBox(
                            width: 70,
                            child: Text(formatAsCurrency(product['price'])),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 12),
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
                                  child: SizedBox(
                                    child: TextField(
                                      style: const TextStyle(fontSize: 12),
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
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 12),
                                  color: const Color.fromARGB(255, 92, 213, 86),
                                  onPressed: () {
                                    updateQuantity(
                                        index, product['quantity'] + 1);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(SizedBox(
                          width: 70,
                          child: Text(formatAsCurrency(totalCost)),
                        )),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ':  ${formatAsCurrency(calculateGrandTotal())}',
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
                        width: 300,
                        child: TextField(
                          controller: _serialNumberController,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 156, 84, 84)),
                            ),
                            labelText: 'Serial Number',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 156, 84, 84)),
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
                        )),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
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
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _discount();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.tag,
                              size: 28), // Adjust size as needed
                        ),
                        const Text('DISCOUNT'),
                      ],
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () {},
                  //   style: ButtonStyle(
                  //     fixedSize: MaterialStateProperty.all(
                  //         const Size(120, 80)), // Adjust the size here
                  //   ),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.all(
                  //             10.0), // Adjust padding as needed
                  //         child: const FaIcon(FontAwesomeIcons.barcode,
                  //             size: 28), // Adjust size as needed
                  //       ),
                  //       const Text('SCAN'),
                  //     ],
                  //   ),
                  // ),
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

                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DropdownMenu(
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
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          _epayment();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(120, 60),
                                        ),
                                        child: const Text('E-PAYMENT'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Cash Payment'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                        'Please collect cash from the customer. Total: ${formatAsCurrency(calculateGrandTotal())}'),
                                                    const SizedBox(
                                                      height: 16,
                                                    ), // Add spacing between text and text field

                                                    TextField(
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
                                                        hintText:
                                                            'Enter amount',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ////ARECEIPT
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      String message = '';
                                                      String title = '';

                                                      if (cashAmount == 0) {
                                                        message +=
                                                            'Please enter cash tendered to proceed.';
                                                        title +=
                                                            '[Enter Amount]';
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
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title:
                                                                    Text(title),
                                                                content: Text(
                                                                    message),
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
                                                            jsonEncode(
                                                                itemsList),
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
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        Colors
                                                            .brown, // Change the color here
                                                      ),
                                                      // Other button styles...
                                                    ),
                                                    child:
                                                        const Text('Proceed'),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Close'))
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(120, 60),
                                        ),
                                        child: const Text('CASH'),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            _remaining();

                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
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
                                                            String
                                                                numericValue =
                                                                value
                                                                    .replaceAll(
                                                              RegExp(
                                                                  '[${CurrencySymbols.PESO},]'),
                                                              '',
                                                            );

                                                            setState(() {
                                                              splitcash = double
                                                                      .tryParse(
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
                                                          height: 50,
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
                                                            String
                                                                numericValue =
                                                                value
                                                                    .replaceAll(
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

                                                            double
                                                                totaltendered =
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
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the dialog
                                                          },
                                                          child: const Text(
                                                              'Close'))
                                                    ],
                                                  );
                                                });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(120, 60),
                                          ),
                                          child: const Text('SPLIT'))
                                    ],
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
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.moneyBill,
                              size: 28), // Adjust size as needed
                        ),
                        const Text('PAYMENT'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      others();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.gears,
                              size: 24), // Adjust size as needed
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
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      services();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.handHolding,
                              size: 24), // Adjust size as needed
                        ),
                        const Text('SERVICES'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      package();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.boxesStacked,
                              size: 24), // Adjust size as needed
                        ),
                        const Text('PACKAGE'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addons();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.boxTissue,
                              size: 24), // Adjust size as needed
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
