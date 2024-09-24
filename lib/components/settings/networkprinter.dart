import 'dart:io';

import 'package:fivelPOS/model/printer.dart';
import 'package:fivelPOS/repository/customerhelper.dart';
import 'package:fivelPOS/repository/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class NetworkPrinterConfig extends StatefulWidget {
  const NetworkPrinterConfig({super.key});

  @override
  State<NetworkPrinterConfig> createState() => _NetworkPrinterConfigState();
}

class _NetworkPrinterConfigState extends State<NetworkPrinterConfig> {
  TextEditingController _printernameController = TextEditingController();
  TextEditingController _printeripaddressController = TextEditingController();
  TextEditingController _printerproductionipaddressController =
      TextEditingController();
  TextEditingController _printerpaperwidthController = TextEditingController();

  PaperSize papersize = PaperSize.mm80;
  String printername = '';
  String printerip = '';
  String productionprinterip = '';
  bool isenable = false;

  @override
  void initState() {
    super.initState();
    _getprinterconfig();
  }

  Future<void> _getprinterconfig() async {
    var printer;
    if (Platform.isWindows) {
      printer = await Helper().readJsonToFile('printer.json');
      print(printer);
    }

    if (Platform.isAndroid) {
      printer = await Helper().jsonToFileReadAndroid('printer.json');
    }

    if (printer['printername'] != null) {
      PrinterModel model = PrinterModel(
          printer['printername'],
          printer['printerip'],
          printer['productionprinterip'],
          printer['papersize'],
          printer['isenable']);

      print(printer['printername']);

      setState(() {
        printername = model.printername;
        printerip = model.printerip;
        productionprinterip = model.productionprinterip;
        papersize = model.papersize == 'mm80' ? PaperSize.mm80 : PaperSize.mm58;

        _printernameController.text = model.printername;
        _printeripaddressController.text = model.printerip;
        _printerproductionipaddressController.text = model.productionprinterip;
        _printerpaperwidthController.text = model.papersize;

        isenable = model.isenable;
      });
    }
  }

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
                    title: const Text('Success'),
                    content: const Text('Printer configuration saved!'),
                    icon: const Icon(Icons.check),
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
            .jsonToFileWriteAndroid(jsnonData, 'printer.json')
            .then((value) => showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Success'),
                    content: const Text('Printer configuration saved!'),
                    icon: const Icon(Icons.check),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 380.0,
            ),
            child: TextField(
              controller: _printernameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
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
              controller: _printeripaddressController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                labelText: 'POS Printer IP Address',
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
              controller: _printerproductionipaddressController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                labelText: 'Production/Kitchen Printer IP Address',
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
              controller: _printerpaperwidthController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                labelText: 'Paper',
                labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                border: OutlineInputBorder(),
                hintText: 'Paper width',
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        savePrinterConfig({
                          'printername': _printernameController.text,
                          'printerip': _printeripaddressController.text,
                          'productionprinterip':
                              _printerproductionipaddressController.text,
                          'papersize': _printerpaperwidthController.text,
                          'isenable': false,
                        });
                      },
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ))),
              Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        String ipaddress = _printeripaddressController.text;
                        LocalPrint().printnetwork(ipaddress);
                      },
                      child: const Text(
                        'TEST PRINT',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ))),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: (!isenable)
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        onPressed: () {
                          setState(() {
                            savePrinterConfig({
                              'printername': _printernameController.text,
                              'printerip': _printeripaddressController.text,
                              'productionprinterip':
                                  _printerproductionipaddressController.text,
                              'papersize': _printerpaperwidthController.text,
                              'isenable': true,
                            });
                            isenable = true;
                          });
                        },
                        child: const Text(
                          'ENABLE',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ))
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            savePrinterConfig({
                              'printername': _printernameController.text,
                              'printerip': _printeripaddressController.text,
                              'productionprinterip':
                                  _printerproductionipaddressController.text,
                              'papersize': _printerpaperwidthController.text,
                              'isenable': false,
                            });

                            isenable = false;
                          });
                        },
                        child: const Text(
                          'DISABLE',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
