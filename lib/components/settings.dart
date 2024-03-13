import 'dart:io';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:fiveLPOS/components/circularprogressbar.dart';
import 'package:fiveLPOS/components/dashboard.dart';
import 'package:fiveLPOS/model/email.dart';
import 'package:fiveLPOS/model/printer.dart';
import 'package:fiveLPOS/repository/customerhelper.dart';
import 'package:fiveLPOS/repository/printing.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String employeeid;
  final String fullname;
  final int accesstype;
  final int positiontype;
  final String logo;
  const SettingsPage(
      {super.key,
      required this.employeeid,
      required this.fullname,
      required this.accesstype,
      required this.positiontype,
      required this.logo});

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
  bool isenable = false;

  var _printer;
  @override
  void initState() {
    // TODO: implement initState
    _printerinitiate();
    _getemailconfig();
    _getprinterconfig();
    super.initState();
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

  Future<void> _getprinterconfig() async {
    if (Platform.isWindows) {
      var printer = await Helper().readJsonToFile('printer.json');
      print(printer);
      if (printer['printername'] != null) {
        PrinterModel model = PrinterModel(printer['printername'],
            printer['printerip'], printer['papersize'], printer['isenable']);

        setState(() {
          printername = model.printername;
          printerip = model.printerip;
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
        PrinterModel model = PrinterModel(printer['printername'],
            printer['printerip'], printer['papersize'], printer['isenable']);

        setState(() {
          printername = model.printername;
          printerip = model.printerip;
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
    papersize = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    print(profile.name);

    final printer = NetworkPrinter(papersize, profile);

    if (Platform.isWindows) {
      printerConfig = await Helper().readJsonToFile('printer.json');
    }

    if (Platform.isAndroid) {
      printerConfig = await Helper().JsonToFileRead('printer.json');
    }

    final PosPrintResult res = await printer.connect(printerConfig['printerip'],
        port: 9100, timeout: const Duration(seconds: 5));

    print('Initial Print: ${res.msg} ${printer.host} ${printer.port}');

    _printer = printer;
    printer.disconnect();
  }

  void isPrinterStatus() {
    _getprinterconfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildBody(),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal.shade400),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Branch: 5L Main'),
                  Text('ID: 9999'),
                  Text('POS ID: 1000'),
                ],
              )),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Printer'),
            onTap: () {
              setState(() {
                currentPage = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            onTap: () {
              setState(() {
                currentPage = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.gif_box),
            title: const Text('Products'),
            onTap: () {
              setState(() {
                currentPage = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.discount),
            title: const Text('Discounts & Promo'),
            onTap: () {
              setState(() {
                currentPage = 3;
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(
            height: 250,
          ),
          const Divider(
            thickness: 4,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    // Navigator.pushReplacementNamed(context, '/dashboard');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyDashboard(
                                employeeid: widget.employeeid,
                                fullname: widget.fullname,
                                accesstype: widget.accesstype,
                                positiontype: widget.positiontype,
                                logo: widget.logo,
                                printer: _printer,
                                printerstatus: '',
                              )),
                    );
                  },
                  icon: const Icon(Icons.arrow_back))
            ],
          )
        ]),
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
            getPrinterConfig: isPrinterStatus);
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
      default:
        return Container();
    }
  }
}

class PrinterPage extends StatelessWidget {
  final String printername;
  final String ipaddress;
  final PaperSize papersize;
  final bool isenable;
  final Function() getPrinterConfig;

  const PrinterPage(
      {super.key,
      required this.printername,
      required this.ipaddress,
      required this.papersize,
      required this.isenable,
      required this.getPrinterConfig});

  @override
  Widget build(BuildContext context) {
    TextEditingController _printername =
        TextEditingController(text: printername);
    TextEditingController _printeripaddress =
        TextEditingController(text: ipaddress);
    TextEditingController _printerpaperwidth =
        TextEditingController(text: papersize.value == 1 ? 'mm58' : 'mm80');
    bool _isenable = isenable;

    Future<void> savePrinterConfig(jsnonData) async {
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
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                  controller: _printername,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'IP Address',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Paper',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
                          'papersize': _printerpaperwidth.text,
                          'isenable': false,
                        });
                      },
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
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
                            fontSize: 22, fontWeight: FontWeight.w600),
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
                  child: (_isenable == false)
                      ? ElevatedButton(
                          onPressed: () {
                            savePrinterConfig({
                              'printername': _printername.text,
                              'printerip': _printeripaddress.text,
                              'papersize': _printerpaperwidth.text,
                              'isenable': true,
                            });
                          },
                          child: const Text(
                            'ENABLE',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ))
                      : ElevatedButton(
                          onPressed: () {
                            savePrinterConfig({
                              'printername': _printername.text,
                              'printerip': _printeripaddress.text,
                              'papersize': _printerpaperwidth.text,
                              'isenable': false,
                            });
                          },
                          child: const Text(
                            'DISABLE',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ))),
            ]),
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
