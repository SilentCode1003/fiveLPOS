import 'dart:convert';
import 'dart:io';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:fiveLPOS/components/dashboard.dart';
import 'package:fiveLPOS/components/settings.dart';
import 'package:fiveLPOS/repository/bluetoothprinter.dart';
import 'package:flutter/material.dart';
import 'package:fiveLPOS/components/posconfig.dart';
import 'package:fiveLPOS/repository/dbhelper.dart';

void main() {
  if (Platform.isAndroid) {
    DatabaseHelper dh = DatabaseHelper();
    dh.database;
  }

  if (Platform.isWindows) {
    createJsonFile('pos.json');
    createJsonFile('email.json');
    createJsonFile('branch.json');
    createJsonFile('printer.json');
    createJsonFile('server.json');
    createJsonFile('products.json');
    createJsonFile('sales.json');
    createJsonFile('refund.json');
  }

  runApp(const MyApp());
}

void createJsonFile(filename) {
  try {
    // Get the current working

    final String currentDirectory = Directory.current.path;

    // Specify the file name and path
    final String filePath = '$currentDirectory/$filename';

    // Create a File object
    final File file = File(filePath);

    if (file.existsSync()) {
      return;
    }

    // Create a Map (or any other data structure) to convert to JSON
    final Map<String, dynamic> jsonData = {'key': 'value'};

    // Convert the Map to a JSON string
    final jsonString = jsonEncode(jsonData);

    // Write the JSON string to the file
    file.writeAsStringSync(jsonString);

    print('JSON file created successfully at: $filePath');
  } catch (e) {
    print('Error creating JSON file: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  get profile => CapabilityProfile.load();
  get printer => NetworkPrinter(PaperSize.mm80, profile);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal),
      ),
      initialRoute: '/', // Set the initial route
      home: const PosConfig(),
      routes: {
        '/setting': (context) => SettingsPage(
              employeeid: '',
              fullname: '',
              accesstype: 0,
              positiontype: 0,
              logo: '',
              printer: printer,
            ),
        '/dashboard': (context) => MyDashboard(
              employeeid: 'employeeid',
              fullname: 'fullname',
              accesstype: 0,
              positiontype: 0,
              logo: 'logo',
              printer: printer,
            ),
        '/bluetooth': (context) => BluetoothPrinterPage()
      },
    );
  }
}
