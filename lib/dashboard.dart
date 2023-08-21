import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pos2/components/areceipt.dart';
import 'package:pos2/repository/customerhelper.dart';
import 'package:pos2/repository/detailsales.dart';
import 'package:pos2/repository/transaction.dart';

class ButtonStyleInfo {
  final Color backgroundColor;
  final Color textColor;

  ButtonStyleInfo({
    required this.backgroundColor,
    required this.textColor,
  });
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyDashboard(),
  ));
}

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});

  @override
  _MyDashboardState createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  List<Map<String, dynamic>> itemsList = [];
  List<Map<String, dynamic>> productList = [];
  Helper helper = Helper();
  int detailid = 0;

  @override
  void initState() {
    // TODO: implement initState
    _getdetailid();
    super.initState();
  }

  Future<void> _getdetailid() async {
    final result = await SalesDetails().getdetailid();
    final id =(result['data']);

    if (result['msg'] == 'success') {
      setState(() {
        detailid = int.parse(id);
        print(detailid);
      });
    }
  }

  String formatAsCurrency(double value) {
    return toCurrencyString(value.toString(),
        leadingSymbol: CurrencySymbols.DOLLAR_SIGN);
  }

  Future<void> confirmAndRemove(int index) async {
    bool shouldRemove = await showDialog(
      context: context,
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
    if (newQuantity < 1) {
      showDialog(
        context: context,
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
        itemsList[index]['quantity'] = newQuantity;
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

  void addItem(name, price, quantity) {
    setState(() {
      int existingIndex = itemsList.indexWhere((item) => item['name'] == name);

      if (existingIndex != -1) {
        setState(() {
          int newQuantity = itemsList[existingIndex]['quantity'] + quantity;
          itemsList[existingIndex]['quantity'] = newQuantity;
        });
      } else {
        setState(() {
          itemsList.add({'name': name, 'price': price, 'quantity': quantity});
        });
      }
    });
  }

  void _showSimpleDialog(BuildContext context, category) {
    productList.clear();
    if (category == 'Paint') {
      productList
          .add({'name': 'Michaela 500g', 'price': 615.00, 'quantity': 1});
      productList.add({'name': 'Fla 500g', 'price': 615.00, 'quantity': 1});
      productList.add({'name': 'Flar 500g', 'price': 615.00, 'quantity': 1});
      productList.add({'name': 'Alrick 500g', 'price': 615.00, 'quantity': 1});
    }

    if (category == 'Brush') {
      productList
          .add({'name': 'Limewash Brush 3x10', 'price': 520.00, 'quantity': 1});
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Products')),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5, // Adjust the spacing between buttons
                  runSpacing: 5, // Adjust the vertical spacing between rows
                  children: [
                    SizedBox(
                      width: 300,
                      height: 550,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () {},
                              title: ElevatedButton(
                                onPressed: () {
                                  addItem(
                                      productList[index]['name'],
                                      productList[index]['price'],
                                      productList[index]['quantity']);
                                },
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(100, 100)),
                                child: Text(productList[index]['name']),
                              ));
                        },
                        itemCount: productList.length,
                      ),
                    )
                    // Add more buttons here...
                  ],
                ),
              ],
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
      },
    );
  }

  Future<void> _transaction(
      String detailid,
      String posid,
      String date,
      String shift,
      String paymenttype,
      String items,
      String total,
      String cashier) async {
    try {
      final result = await Transaction().sending(
          detailid, date, posid, shift, paymenttype, items, total, cashier);

      if (result['msg'] == 'success') {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Transaction process successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReceiptScreen(
                            cash: cashAmount,
                            items: itemsList,
                            cashier: cashier,
                            detailid: detailid,
                            posid: posid,
                            shift: shift,
                          ),
                        ),
                      );
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
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
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Transaction Error'),
              content: const Text('Please inform administrator. Thank you!'),
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
      itemsList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        leading: Container(
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          child: Image.asset('assets/asvesti.png'),
        ),
        title: const Text('Asvesti'),
        actions: <Widget>[
          Row(
            children: [
              const Text('Logout'),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Add your logout logic here
                  // For example: Navigator.pushReplacementNamed(context, '/login');
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
                height: 300,
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
                    // columnSpacing: 20,
                    columns: const [
                      DataColumn(
                          label: Text('Prdct Name',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('UNIT PRICE',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('QTY.',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Total Cost',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('')),
                    ],
                    rows: itemsList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> product = entry.value;
                      double totalCost = product['price'] * product['quantity'];
                      return DataRow(cells: [
                        DataCell(Text(product['name'])),
                        DataCell(Text(formatAsCurrency(product['price']))),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              color: const Color.fromARGB(255, 213, 86, 86),
                              onPressed: () {
                                if (product['quantity'] > 0) {
                                  updateQuantity(
                                      index, product['quantity'] - 1);
                                }
                              },
                            ),
                            Expanded(
                              child: SizedBox(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (newQuantity) {
                                    int parsedQuantity =
                                        int.tryParse(newQuantity) ?? 0;
                                    updateQuantity(index, parsedQuantity);
                                  },
                                  controller: TextEditingController(
                                      text: product['quantity'].toString()),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              color: const Color.fromARGB(255, 92, 213, 86),
                              onPressed: () {
                                updateQuantity(index, product['quantity'] + 1);
                              },
                            ),
                          ],
                        )),
                        DataCell(Text(formatAsCurrency(totalCost))),
                        DataCell(IconButton(
                          icon: const Icon(Icons.delete),
                          color: const Color.fromARGB(255, 58, 58, 67),
                          onPressed: () => confirmAndRemove(index),
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
                        'Grand Total',
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
            SizedBox(
                width: 300,
                child: TextField(
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 156, 84, 84)),
                    ),
                    labelText: 'Serial Number',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 156, 84, 84)),
                    border: OutlineInputBorder(),
                    hintText: 'Enter Serial',
                    prefixIcon: Icon(Icons.qr_code_2_outlined),
                  ),
                  textInputAction: TextInputAction.go,
                  onEditingComplete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter pressed!'),
                      ),
                    );
                  },
                )),

            const SizedBox(
              width: 50,
            ),
            const SizedBox(height: 10), //DIVIDER START

            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(200, 100)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.barcode,
                              size: 48), // Adjust size as needed
                        ),
                        const Text('SCAN'),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print(itemsList.length);
                      }
                      if (itemsList.isEmpty) {
                        showDialog(
                            context: context,
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
                          builder: (BuildContext context) {
                            return AlertDialog(
                              // alignment: Alignment.center,
                              title: const Text(
                                'CASH',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 100),
                                    ),
                                    child: const Text('E-PAYMENT'),
                                  ),
                                  const SizedBox(
                                      width: 16), // Add spacing between buttons

                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Cash Payment'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                    'Please collect cash from the customer.'),
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
                                                              .DOLLAR_SIGN,
                                                    ),
                                                  ],
                                                  onChanged: (value) {
                                                    // Remove currency symbols and commas to get the numeric value
                                                    String numericValue =
                                                        value.replaceAll(
                                                      RegExp(
                                                          '[${CurrencySymbols.DOLLAR_SIGN},]'),
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
                                                onPressed: () {
                                                  String message = "";
                                                  String title = "";

                                                  if (cashAmount == 0) {
                                                    message +=
                                                        "Please enter cash tendered to proceed.";
                                                    title += "[Enter Amount]";
                                                  }
                                                  if (cashAmount <
                                                      calculateGrandTotal()) {
                                                    message +=
                                                        "Please enter the right amount of cash.";
                                                    title +=
                                                        "[Insufficient Funds]";
                                                  }

                                                  if (message != "") {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(title),
                                                            content:
                                                                Text(message),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
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
                                                        '1',
                                                        helper
                                                            .GetCurrentDatetime(),
                                                        '1',
                                                        'CASH',
                                                        jsonEncode(itemsList),
                                                        calculateGrandTotal()
                                                            .toString(),
                                                        'Joseph Orencio');
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(
                                                    Colors
                                                        .brown, // Change the color here
                                                  ),
                                                  // Other button styles...
                                                ),
                                                child: const Text('Proceed'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 100),
                                    ),
                                    child: const Text('CASH'),
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
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(200, 100)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.moneyBill,
                              size: 48), // Adjust size as needed
                        ),
                        const Text('PAYMENT'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ), //END
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // child: CategoryButtons(),
            ),

            const Center(
              child: Text('Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, // Adjust the spacing between buttons
              runSpacing: 8, // Adjust the vertical spacing between rows
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSimpleDialog(context, 'Paint');
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 100)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            5.0), // Adjust padding as needed
                        child: const Icon(
                          Icons.format_color_fill,
                          size: 40,
                        ), // Adjust size as needed
                      ),
                      const Text('PAINT'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showSimpleDialog(context, 'Brush');
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 100)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            5.0), // Adjust padding as needed
                        child: const Icon(
                          Icons.imagesearch_roller_outlined,
                          size: 40,
                        ), // Adjust size as needed
                      ),
                      const Text('BRUSH'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 100)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            5.0), // Adjust padding as needed
                        child: const Icon(
                          Icons.select_all,
                          size: 40,
                        ), // Adjust size as needed
                      ),
                      const Text('SEALER & Accs.'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle the first button press
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 100)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            5.0), // Adjust padding as needed
                        child: const Icon(
                          Icons.miscellaneous_services,
                          size: 40,
                        ), // Adjust size as needed
                      ),
                      const Text('OTHERS'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptScreen extends StatefulWidget {
  double cash;
  List<Map<String, dynamic>> items;
  String detailid;
  String posid;
  String cashier;
  String shift;

  ReceiptScreen(
      {super.key,
      required this.cash,
      required this.items,
      required this.detailid,
      required this.posid,
      required this.shift,
      required this.cashier});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: Center(
        child: AReceipt(
          cash: widget.cash,
          items: widget.items,
          cashier: widget.cashier,
          detailid: widget.detailid,
          posid: widget.posid,
          shift: widget.shift,
        ),
      ),
    );
  }
}
