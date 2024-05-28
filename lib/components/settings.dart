import 'dart:io';

import 'package:flutter_esc_pos_bluetooth/flutter_esc_pos_bluetooth.dart'
    as bluetooth;
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:fiveLPOS/components/circularprogressbar.dart';
import 'package:fiveLPOS/components/dashboard.dart';
import 'package:fiveLPOS/model/branch.dart';
import 'package:fiveLPOS/model/email.dart';
import 'package:fiveLPOS/model/pos.dart';
import 'package:fiveLPOS/model/printer.dart';
import 'package:fiveLPOS/repository/bluetoothprinter.dart';
import 'package:fiveLPOS/repository/customerhelper.dart';
import 'package:fiveLPOS/repository/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  final String employeeid;
  final String fullname;
  final int accesstype;
  final int positiontype;
  final String logo;
  const SettingsPage({
    super.key,
    required this.employeeid,
    required this.fullname,
    required this.accesstype,
    required this.positiontype,
    required this.logo,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentPage = 1;
  String emailaddress = '';
  String emailpassword = '';
  String smtp = '';

  PaperSize papersize = PaperSize.mm80;
  String printername = '';
  String printerip = '';
  String productionprinterip = '';
  bool isenable = false;

  String branchid = '';
  String branchname = '';

  int posid = 0;
  String posname = '';
  String serial = '';
  String min = '';
  String ptu = '';
  String status = '';
  String createdby = '';
  String createddate = '';

  bool _ischange = false;

  bluetooth.PrinterBluetoothManager printerManager =
      bluetooth.PrinterBluetoothManager();
  List<bluetooth.PrinterBluetooth> _devices = [];

  List<String> _selectPrinterType = [
    'Select Type',
    'Network',
    'Bluetooth',
  ];

  var _printer;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  @override
  void initState() {
    // TODO: implement
    if (Platform.isAndroid) {
      _printerinitiate();
      _getprinterconfig();
    }

    _getemailconfig();
    _getposconfig();
    _getbranchconfig();
    _requestBluetoothPermissions();

    super.initState();
  }

  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      // Permissions granted
    } else {
      // Handle the case when permissions are not granted
      // You may want to show a message to the user and re-request permissions
    }
  }

  Future<void> _getemailconfig() async {
    if (Platform.isWindows) {
      var email = await Helper().readJsonToFile('email.json');

      print(email);
      EmailModel model = EmailModel(
          email['emailaddress'], email['emailpassword'], email['emailserver']);

      setState(() {
        emailaddress = model.emailaddress;
        emailpassword = model.emailpassword;
        smtp = model.emailserver;
      });
    }

    if (Platform.isAndroid) {
      var email = await Helper().JsonToFileRead('email.json');
      print(email);
      EmailModel model = EmailModel(
          email['emailaddress'], email['emailpassword'], email['emailserver']);

      setState(() {
        emailaddress = model.emailaddress;
        emailpassword = model.emailpassword;
        smtp = model.emailserver;
      });
    }
  }

  Future<void> _getbranchconfig() async {
    if (Platform.isWindows) {
      var branch = await Helper().readJsonToFile('branch.json');

      print(branch);
      BranchModel model =
          BranchModel(branch['branchid'], branch['branchname'], '', '', '');

      setState(() {
        branchid = model.branchid;
        branchname = model.branchname;
      });
    }

    if (Platform.isAndroid) {
      var branch = await Helper().JsonToFileRead('branch.json');
      print(branch);
      BranchModel model =
          BranchModel(branch['branchid'], branch['branchname'], '', '', '');

      setState(() {
        branchid = model.branchid;
        branchname = model.branchname;
      });
    }
  }

  Future<void> _getposconfig() async {
    if (Platform.isWindows) {
      var pos = await Helper().readJsonToFile('pos.json');

      print(pos);
      POSModel model = POSModel(
          pos['posid'],
          pos['posname'],
          pos['serial'],
          pos['min'],
          pos['ptu'],
          pos['status'],
          pos['createdby'],
          pos['createddate']);

      setState(() {
        posid = model.posid;
        posname = model.posname;
      });
    }

    if (Platform.isAndroid) {
      var pos = await Helper().JsonToFileRead('pos.json');
      print(pos);
      POSModel model = POSModel(
          pos['posid'],
          pos['posname'],
          pos['serial'],
          pos['min'],
          pos['ptu'],
          pos['status'],
          pos['createdby'],
          pos['createddate']);

      setState(() {
        posid = model.posid;
        posname = model.posname;
      });
    }
  }

  Future<void> _getprinterconfig() async {
    if (Platform.isWindows) {
      var printer = await Helper().readJsonToFile('printer.json');
      print(printer);
      if (printer['printername'] != null) {
        PrinterModel model = PrinterModel(
            printer['printername'],
            printer['printerip'],
            printer['productionprinterip'],
            printer['papersize'],
            printer['isenable']);

        setState(() {
          printername = model.printername;
          printerip = model.printerip;
          productionprinterip = model.productionprinterip;
          papersize =
              model.papersize == 'mm80' ? PaperSize.mm80 : PaperSize.mm58;
        });
        isenable = model.isenable;
      }
    }

    if (Platform.isAndroid) {
      var printer = await Helper().JsonToFileRead('printer.json');

      print(printer);
      if (printer['printername'] != null) {
        PrinterModel model = PrinterModel(
            printer['printername'],
            printer['printerip'],
            printer['productionprinterip'],
            printer['papersize'],
            printer['isenable']);

        setState(() {
          printername = model.printername;
          printerip = model.printerip;
          productionprinterip = model.productionprinterip;
          papersize =
              model.papersize == 'mm80' ? PaperSize.mm80 : PaperSize.mm58;
          isenable = model.isenable;
        });
      }
    }
  }

  void changePage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  void _printerinitiate() async {
    Map<String, dynamic> printerConfig = {};

    if (Platform.isWindows) {
      printerConfig = await Helper().readJsonToFile('printer.json');
    }

    if (Platform.isAndroid) {
      printerConfig = await Helper().JsonToFileRead('printer.json');
    }
    final printer = PrinterNetworkManager(printerConfig['ipaddress']);
    _printer = printer;
  }

  void isPrinterStatus() {
    _getprinterconfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: currentPage,
              groupAlignment: groupAlignment,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPage = index;
                });
              },
              labelType: labelType,
              leading: showLeading
                  ? FloatingActionButton(
                      elevation: 0,
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      child: const Icon(Icons.add),
                    )
                  : const SizedBox(),
              trailing: showTrailing
                  ? IconButton(
                      onPressed: () {
                        // Add your onPressed code here!
                      },
                      icon: const Icon(Icons.more_horiz_rounded),
                    )
                  : const SizedBox(),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.print),
                  selectedIcon: Icon(Icons.print),
                  label: Text('Printers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.email),
                  selectedIcon: Icon(Icons.email),
                  label: Text('Email'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory),
                  selectedIcon: Icon(Icons.inventory),
                  label: Text('Products'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.discount),
                  selectedIcon: Icon(Icons.discount),
                  label: Text('Promo & Discounts'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.exit_to_app),
                  selectedIcon: Icon(Icons.exit_to_app),
                  label: Text('Exit'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 4),
            Expanded(child: buildBody()),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    switch (currentPage) {
      case 0:
        return PrinterPage(
          printername: printername,
          ipaddress: printerip,
          papersize: papersize,
          isenable: isenable,
          getPrinterConfig: isPrinterStatus,
          printer: _printer,
          printertype: _ischange,
          productionipaddress: productionprinterip,
        );
      case 1:
        return EmailPage(
          emailaddress: emailaddress,
          emailpassword: emailaddress,
          smtp: smtp,
        );
      case 2:
        return const ProductPage();
      case 3:
        return const DiscountPromoPage();
      case 4:
        return AlertDialog(
          title: const Text('Return'),
          content: const Text('Click click button to return.'),
          backgroundColor: Colors.grey,
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Retrun to Dashboard')),
          ],
        );
      default:
        return Container();
    }
  }

  PreferredSizeWidget buildAppBar() {
    switch (currentPage) {
      case 0:
        return AppBar(
          centerTitle: true,
          actions: <Widget>[
            DropdownMenu(
              width: 420,
              initialSelection: _selectPrinterType.first,
              textStyle: const TextStyle(color: Colors.white),
              onSelected: (String? value) {
                setState(() {
                  if (value == 'Network') {
                    _ischange = true;
                  }
                  if (value == 'Bluetooth') {
                    _ischange = false;
                  }
                });
              },
              dropdownMenuEntries: _selectPrinterType
                  .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            )
          ],
        );
      case 1:
        return AppBar();
      case 2:
        return AppBar();
      case 3:
        return AppBar();
      default:
        return AppBar();
    }
  }
}

class PrinterPage extends StatefulWidget {
  final String printername;
  final String ipaddress;
  final String productionipaddress;
  final PaperSize papersize;
  final bool isenable;
  final Function() getPrinterConfig;
  final PrinterNetworkManager? printer;
  final bool printertype;

  const PrinterPage(
      {super.key,
      required this.printername,
      required this.ipaddress,
      required this.papersize,
      required this.isenable,
      required this.getPrinterConfig,
      required this.printer,
      required this.printertype,
      required this.productionipaddress});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  Widget build(BuildContext context) {
    TextEditingController _printername =
        TextEditingController(text: widget.printername);
    TextEditingController _printeripaddress =
        TextEditingController(text: widget.ipaddress);
    TextEditingController _printerproductionipaddress =
        TextEditingController(text: widget.productionipaddress);
    TextEditingController _printerpaperwidth = TextEditingController(
        text: widget.papersize.value == 1 ? 'mm58' : 'mm80');

    bluetooth.PrinterBluetoothManager printerManager =
        bluetooth.PrinterBluetoothManager();
    List<bluetooth.PrinterBluetooth> _devices = [];
    bool _isenable = widget.isenable;

    Future<void> savePrinterConfig(jsnonData) async {
      setState(() async {
        if (Platform.isWindows) {
          await Helper()
              .writeJsonToFile(jsnonData, 'printer.json')
              .then((value) => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Success'),
                      content: Text('Printer configuration saved!'),
                      icon: Icon(Icons.check),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  }));
        }
        if (Platform.isAndroid) {
          await Helper()
              .JsonToFileWrite(jsnonData, 'printer.json')
              .then((value) => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Success'),
                      content: Text('Printer configuration saved!'),
                      icon: Icon(Icons.check),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  }));
        }
      });
    }

    Stream<bool> isEnable(bool value) {
      print(value);
      return Stream<bool>.value(value);
    }

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.printertype
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 200.0,
                            maxWidth: 380.0,
                          ),
                          child: TextField(
                            controller: _printername,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              labelText: 'Name',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              border: OutlineInputBorder(),
                              hintText: 'Priter Name',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 200.0,
                            maxWidth: 380.0,
                          ),
                          child: TextField(
                            controller: _printeripaddress,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              labelText: 'POS Printer IP Address',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              border: OutlineInputBorder(),
                              hintText: 'Printer IP Address',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 200.0,
                            maxWidth: 380.0,
                          ),
                          child: TextField(
                            controller: _printerproductionipaddress,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              labelText:
                                  'Production/Kitchen Printer IP Address',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              border: OutlineInputBorder(),
                              hintText: 'Printer IP Address',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 200.0,
                            maxWidth: 380.0,
                          ),
                          child: TextField(
                            controller: _printerpaperwidth,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              labelText: 'Paper',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              border: OutlineInputBorder(),
                              hintText: 'Paper width',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              minWidth: 200.0,
                              maxWidth: 380.0,
                            ),
                            child: ElevatedButton(
                                onPressed: () {
                                  savePrinterConfig({
                                    'printername': _printername.text,
                                    'printerip': _printeripaddress.text,
                                    'productionprinterip':
                                        _printerproductionipaddress.text,
                                    'papersize': _printerpaperwidth.text,
                                    'isenable': false,
                                  });
                                },
                                child: const Text(
                                  'SAVE',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600),
                                ))),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                              minWidth: 200.0,
                              maxWidth: 380.0,
                            ),
                            child: ElevatedButton(
                                onPressed: () {
                                  String ipaddress = _printeripaddress.text;
                                  LocalPrint().printnetwork(ipaddress);
                                },
                                child: const Text(
                                  'TEST PRINT',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600),
                                ))),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 40,
                            minWidth: 200.0,
                            maxWidth: 380.0,
                          ),
                          child: StreamBuilder(
                            stream: isEnable(_isenable),
                            initialData: false,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              return Container(
                                child: (!snapshot.data)
                                    ? ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            savePrinterConfig({
                                              'printername': _printername.text,
                                              'printerip':
                                                  _printeripaddress.text,
                                              'productionprinterip':
                                                  _printerproductionipaddress
                                                      .text,
                                              'papersize':
                                                  _printerpaperwidth.text,
                                              'isenable': true,
                                            });
                                            _isenable = true;
                                          });
                                        },
                                        child: const Text(
                                          'ENABLE',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600),
                                        ))
                                    : ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            savePrinterConfig({
                                              'printername': _printername.text,
                                              'printerip':
                                                  _printeripaddress.text,
                                              'productionprinterip':
                                                  _printerproductionipaddress
                                                      .text,
                                              'papersize':
                                                  _printerpaperwidth.text,
                                              'isenable': false,
                                            });

                                            _isenable = false;
                                          });
                                        },
                                        child: const Text(
                                          'DISABLE',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600),
                                        )),
                              );
                            },
                          ),
                        )
                      ])
                : const BluetoothPrinterPage(),
          ),
        ),
      ),
    );
  }
}

class EmailPage extends StatelessWidget {
  final String emailaddress;
  final String emailpassword;
  final String smtp;

  const EmailPage({
    super.key,
    required this.emailaddress,
    required this.emailpassword,
    required this.smtp,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController _emailaddress =
        TextEditingController(text: emailaddress);
    TextEditingController _emailpassword =
        TextEditingController(text: emailpassword);
    TextEditingController _smtpserver = TextEditingController(text: smtp);

    Future<void> saveEmailConfig(jsnonData) async {
      if (Platform.isWindows) {
        await Helper()
            .writeJsonToFile(jsnonData, 'email.json')
            .then((value) => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Success'),
                    content: Text('Email configuration saved!'),
                    icon: Icon(Icons.check),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }));
      }
      if (Platform.isAndroid) {
        await Helper()
            .JsonToFileWrite(jsnonData, 'email.json')
            .then((value) => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Success'),
                    content: Text('Email configuration saved!'),
                    icon: Icon(Icons.check),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }));
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 380.0,
            ),
            child: TextField(
              controller: _emailaddress,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Email Address',
                  prefixIcon: Icon(Icons.email)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 380.0,
            ),
            child: TextField(
              controller: _emailpassword,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Email Password',
                  prefixIcon: Icon(Icons.password)),
              obscureText: true,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 380.0,
            ),
            child: TextField(
              controller: _smtpserver,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'SMTP',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'SMTP Server',
                  prefixIcon: Icon(Icons.desktop_windows)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: ElevatedButton(
                  onPressed: () {
                    saveEmailConfig({
                      'emailaddress': _emailaddress.text,
                      'emailpassword': _emailpassword.text,
                      'emailserver': _smtpserver.text
                    });
                  },
                  child: const Text(
                    'SAVE',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  )))
        ],
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  get label => null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.production_quantity_limits),
                  label: const Text('Item Name')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.category_sharp),
                  label: const Text(
                    'Category',
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscountPromoPage extends StatelessWidget {
  const DiscountPromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.discount),
                  label: const Text('Discounts')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.list),
                  label: const Text(
                    'Promo',
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [],
    );
  }
}
