import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos2/components/dashboard.dart';
import 'package:pos2/repository/dbhelper.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../model/userinfo.dart';
import '../api/login.dart';
import 'loadingspinner.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'POS Shift Login',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoginPage(),
//     );
//   }
// }

class LoginPage extends StatefulWidget {
  String logo;
  LoginPage({super.key, required this.logo});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String branchid = '';
  String branchname = '';
  String tin = '';
  String address = '';

  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    // _getbranchdetail();
    super.initState();
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading...',
          );
        });

    final response = await Login().authenticate(username, password);

    if (response['msg'] == 'success') {
      final jsonData = json.encode(response['data']);
      final results = json.decode(jsonData);
      UserInfoModel userinfomodel = UserInfoModel(
          results[0]['employeeid'].toString(),
          results[0]['fullname'],
          results[0]['position'],
          results[0]['contactinfo'],
          results[0]['datehired'],
          results[0]['usercode'],
          results[0]['accesstype'],
          results[0]['status']);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyDashboard(
                  accesstype: userinfomodel.accesstype,
                  employeeid: userinfomodel.employeeid,
                  fullname: userinfomodel.fullname,
                  positiontype: userinfomodel.position,
                  logo: widget.logo,
                )),
      );
    } else {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Access'),
          content: const Text('Incorrect username and password'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  height: 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: ClipOval(
                        child: SvgPicture.string(
                            '<svg ${utf8.decode(base64.decode(widget.logo)).split('<svg')[1].replaceAll(RegExp(r'\n'), '')}'),
                      ))),
              Padding(
                padding: EdgeInsets.all(40),
                child: SizedBox(
                  width: 400,
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onLongPress: () {
                          _login();
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 80)),
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
