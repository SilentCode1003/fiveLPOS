import 'dart:convert';
import 'dart:io';

import 'package:fivelPOS/components/receipts.dart';
import 'package:path_provider/path_provider.dart';

import 'components/dashboard.dart';
import 'components/posconfig.dart';
import 'components/settings.dart';
import 'package:flutter/material.dart';

void main() {
  if (Platform.isWindows) {
    createJsonFile('user.json');
    createJsonFile('pos.json');
    createJsonFile('email.json');
    createJsonFile('branch.json');
    createJsonFile('printer.json');
    createJsonFile('server.json');

    createJsonFile('category.json');
    createJsonFile('productprice.json');
    createJsonFile('discount.json');
    createJsonFile('promo.json');
    createJsonFile('payments.json');
    createJsonFile('employees.json');
    createJsonFile('posdetailid.json');
    createJsonFile('posshift.json');

    createJsonFile('sales.json');
    createJsonFile('refund.json');
    createJsonFile('splitpayment.json');

    createJsonFile('networkstatus.json');
  }

  runApp(const MyApp());
}

void createJsonFile(filename) {
  try {
    // Get the current working

    final currentDirectory = Platform.isAndroid
        ? getApplicationDocumentsDirectory()
        : Directory.current.path;

    // Specify the file name and path
    final String filePath = '$currentDirectory/$filename';

    // Create a File object
    final File file = File(filePath);

    if (file.existsSync()) {
      return;
    }

    // Convert the Map to a JSON string
    Map<String, dynamic> jsonData = {};
    jsonData = {'key': 'value'};
    if (filename == 'branch.json') {
      jsonData = {};
    }

    if (filename == 'pos.json') {
      jsonData = {};
    }

    if (filename == 'email.json') {
      jsonData = {};
    }

    if (filename == 'printer.json') {
      jsonData = {
        'printername': '',
        'printerip': '',
        'papersize': '',
      };
    }

    if (filename == 'user.json') {
      jsonData = {
        'APK':
            'e7e21a794cec6b17c095679a3410759c952a6a2cdd4870611647110d6a8a6c432df458db3ca56d015d00d660482992a61dd192d0afb92d1a158bfc6c60dd30059b72f54995549d2f876d1a6913689f1741de28044d06b1eceb729905eaef24ddd7de6f1244f6a93d59e793c08465c53ed867b9a20f90b7d505e96eebc9a8e572cdab167a327e3245b6a5af913a7f6ad7a2649e6e5be0fa70231c25ff9787cfc92558f7d9fcf093a15024ff688b1b72fec9b0794657ed1cfb8e4f9f52f226a1aa6264e6f9e90f7da274d048fdafcb708d479fae6fbf248ed37c14daa27594ce4aa6dc904149ad4f2468481d6ae0f5f3594c8eb35c0fbe03b6bf8e453a3206f741e974f2e0a15a0a4284e89e8c6b0f2aeaeefe92899beb450e015141e95613619f5c95ee238e96aab7d994679bc90fdbf811eb50e81020cd123ac878ec87d8c73e',
      };
    }

    String jsonString = jsonEncode(jsonData);
    if (filename == 'sales.json' ||
        filename == 'splitpayment.json' ||
        filename == 'refund.json') {
      jsonString = '[]';
    }

    // Write the JSON string to the file
    file.writeAsStringSync(jsonString);

    print('JSON file created successfully at: $filePath');
  } catch (e) {
    print('Error creating JSON file: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal, brightness: Brightness.light),
          dialogBackgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(color: Colors.teal),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(Colors.grey),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ))),

      initialRoute: '/', // Set the initial route
      home: const PosConfig(),
      routes: {
        '/setting': (context) => const SettingsPage(
              employeeid: '',
              fullname: '',
              accesstype: 0,
              positiontype: 0,
              logo: '',
            ),
        '/dashboard': (context) => const MyDashboard(
              employeeid: 'employeeid',
              fullname: 'fullname',
              accesstype: 0,
              positiontype: 0,
              logo: 'logo',
            ),
        '/receipt': (context) => ReceiptPage(
              reprint: () {},
              refund: () {},
              email: () {},
              orderslip: () {},
              posid: '',
            ),
      },
    );
  }
}
