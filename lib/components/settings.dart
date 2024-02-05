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
        PrinterModel model = PrinterModel(
            printer['printername'], printer['printerip'], printer['papersize']);

        setState(() {
          printername = model.printername;
          printerip = model.printerip;
          papersize =
              model.papersize == 'mm80' ? PaperSize.mm80 : PaperSize.mm58;
        });
      }
    }

    if (Platform.isAndroid) {
      var printer = await Helper().JsonToFileRead('email.json');

      print(printer);
      if (printer['printername'] != null) {
        PrinterModel model = PrinterModel(
            printer['printername'], printer['printerip'], printer['papersize']);

        setState(() {
          printername = model.printername;
          printerip = model.printerip;
          papersize =
              model.papersize == 'mm80' ? PaperSize.mm80 : PaperSize.mm58;
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
    papersize = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    print(profile.name);

    final printer = NetworkPrinter(papersize, profile);

    final PosPrintResult res = await printer.connect('192.168.10.120',
        port: 9100, timeout: const Duration(seconds: 1));

    print('Initial Print: ${res.msg} ${printer.host} ${printer.port}');
    _printer = printer;
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
      default:
        return Container();
    }
  }
}

class PrinterPage extends StatelessWidget {
  final String printername;
  final String ipaddress;
  final PaperSize papersize;
  const PrinterPage(
      {super.key,
      required this.printername,
      required this.ipaddress,
      required this.papersize});

  @override
  Widget build(BuildContext context) {
    TextEditingController _printername =
        TextEditingController(text: printername);
    TextEditingController _printeripaddress =
        TextEditingController(text: ipaddress);
    TextEditingController _printerpaperwidth =
        TextEditingController(text: papersize.value == 1 ? 'mm80' : 'mm58');

    print(papersize.value);

    Future<void> savePrinterConfig(jsnonData) async {
      print(jsnonData);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CircularProgressBar(
              status: '..Writing JSON data..',
            );
          });

      await Helper()
          .writeJsonToFile(jsnonData, 'printer.json')
          .then((value) => Navigator.of(context).pop());
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
                          'papersize': _printerpaperwidth.text
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
                      )))
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
      print(jsnonData);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CircularProgressBar(
              status: '..Writing JSON data..',
            );
          });

      await Helper()
          .writeJsonToFile(jsnonData, 'email.json')
          .then((value) => Navigator.of(context).pop());
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

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class DiscountPromoPage extends StatelessWidget {
  const DiscountPromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
