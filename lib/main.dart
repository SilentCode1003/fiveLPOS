import 'dart:convert';
import 'dart:io';

import 'package:fivelPOS/components/receipts.dart';

import 'components/dashboard.dart';
import 'components/posconfig.dart';
import 'components/settings.dart';
import 'repository/dbhelper.dart';
import 'package:flutter/material.dart';

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
            ),
      },
    );
  }
}
