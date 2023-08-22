import 'package:flutter/material.dart';
import 'package:pos2/components/loginpage.dart';
import 'package:pos2/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown),
      ),
      initialRoute: '/', // Set the initial route
      home: LoginPage(),
    );
  }
}
