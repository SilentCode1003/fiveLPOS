import 'dart:io';
import 'dart:typed_data';
import 'package:fiveLPOS/repository/customerhelper.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_esc_pos_bluetooth/flutter_esc_pos_bluetooth.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return OKToast(
//       child: MaterialApp(
//         title: 'Bluetooth demo',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: BluetoothPrinterPage(title: 'Bluetooth demo'),
//       ),
//     );
//   }
// }

class BluetoothPrinterPage extends StatefulWidget {
  const BluetoothPrinterPage({
    Key? key,
  }) : super(key: key);

  @override
  _BluetoothPrinterPageState createState() => _BluetoothPrinterPageState();
}

class _BluetoothPrinterPageState extends State<BluetoothPrinterPage> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();

    printerManager.scanResults.listen((devices) async {
      //print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(const Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  Future<List<int>> demoReceipt(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];

//Print image
    final ByteData data = await rootBundle.load('assets/logo.png');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final Image? image = decodeImage(imageBytes);

    bytes += ticket.image(image!);
    bytes += ticket.text('TEST PRINT',
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1);

    bytes += ticket.text('Company: 5L Solutions Supplys & Allied Services Inc.',
        styles: PosStyles(align: PosAlign.center, bold: true), linesAfter: 1);
    bytes += ticket.text('Developer: Joseph A. Orencio',
        styles: PosStyles(align: PosAlign.left, bold: true));
    bytes += ticket.text('Contact: 09364423663',
        styles: PosStyles(align: PosAlign.left, bold: true));
    bytes += ticket.text('Web: https://www.5lsolutions.com/',
        styles: PosStyles(align: PosAlign.left, bold: true), linesAfter: 1);

    bytes += ticket.feed(2);
    bytes += ticket.cut();
    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    print(
        'namae:${printer.name} address:${printer.address} type:${printer.type}');
    Map<String, dynamic> device = {
      'name': printer.name,
      'address': printer..deviceName,
      'type': printer.address,
      'isbluetooth': true,
      'printername': '',
      'printerip': '',
      'papersize': '',
      'isenable': false,
    };

    // BluetoothDevice mydevice = BluetoothDevice.fromJson(device);
    printerManager.selectPrinter(printer);
    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    // TEST PRINT
    // final PosPrintResult res =
    // await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT
    await printerManager
        .printTicket((await demoReceipt(paper, profile)))
        .then((res) {
      print(res.msg);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              icon: Icon(
                Icons.check,
                color: Colors.green,
              ),
              title: const Text('Test Print'),
              content: Text(res.msg),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'))
              ],
            );
          });

      // setState(() {
      //   if (Platform.isWindows) {
      //     await Helper()
      //         .writeJsonToFile(device, 'printer.json')
      //         .then((value) => showDialog(
      //             context: context,
      //             barrierDismissible: false,
      //             builder: (context) {
      //               return AlertDialog(
      //                 title: Text('Success'),
      //                 content: Text('Printer configuration saved!'),
      //                 icon: Icon(Icons.check),
      //                 actions: [
      //                   TextButton(
      //                     onPressed: () => Navigator.pop(context),
      //                     child: const Text('OK'),
      //                   ),
      //                 ],
      //               );
      //             }));
      //   }
      //   if (Platform.isAndroid) {
      //     await Helper()
      //         .JsonToFileWrite(device, 'printer.json')
      //         .then((value) => showDialog(
      //             context: context,
      //             barrierDismissible: false,
      //             builder: (context) {
      //               return AlertDialog(
      //                 title: Text('Success'),
      //                 content: Text('Printer configuration saved!'),
      //                 icon: Icon(Icons.check),
      //                 actions: [
      //                   TextButton(
      //                     onPressed: () => Navigator.pop(context),
      //                     child: const Text('OK'),
      //                   ),
      //                 ],
      //               );
      //             }));
      //   }
      // });
    });

    // showToast(res.msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () => _testPrint(_devices[index]),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.print),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name),
                              Text(_devices[index].address),
                              Text(
                                'Click to print a test receipt',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              ),
            );
          }),
      floatingActionButton: StreamBuilder<bool>(
        stream: printerManager.isScanningStream,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: _stopScanDevices,
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: _startScanDevices,
            );
          }
        },
      ),
    );
  }
}
