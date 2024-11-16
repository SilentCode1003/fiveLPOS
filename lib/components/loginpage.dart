import 'dart:convert';
import 'dart:io';

// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fivelPOS/main.dart';
import 'package:flutter/widgets.dart';

import 'package:fivelPOS/repository/customerhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/components/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';

import '../model/userinfo.dart';
import '../api/login.dart';
import 'loadingspinner.dart';

class LoginPage extends StatefulWidget {
  final String logo;
  const LoginPage({super.key, required this.logo});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String branchid = '';
  String branchname = '';
  String tin = '';
  String address = '';
  String branchlogo = '';

  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
    setState(() {
      List<String> logo =
          utf8.decode(base64.decode(widget.logo)).split('<svg ');
      branchlogo = '<svg ${logo[1].replaceAll(RegExp(r'\n'), ' ')}';
    });
  }

  Future<void> _loadRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _saveRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _usernameController.text);
    prefs.setString('password', _passwordController.text);
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

    // final isOnline = await Helper().hasInternetConnection();

    // print(isOnline);

    // if (!isOnline) {
    Map<String, dynamic> offlineData = {};
    if (Platform.isWindows) {
      offlineData = await Helper().readJsonToFile('user.json');
    }
    if (Platform.isAndroid) {
      offlineData = await Helper().jsonToFileReadAndroid('user.json');
    }

    Navigator.of(context).pop();

    UserInfoModel userinfomodel = UserInfoModel(
        offlineData['employeeid'].toString(),
        offlineData['fullname'],
        offlineData['position'],
        offlineData['contactinfo'],
        offlineData['datehired'],
        offlineData['usercode'],
        offlineData['accesstype'],
        offlineData['status'],
        offlineData['APK']);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MyDashboard(
                accesstype: userinfomodel.accesstype,
                employeeid: userinfomodel.employeeid,
                fullname: userinfomodel.fullname,
                positiontype: userinfomodel.position,
                logo: branchlogo,
              )),
    );
    // } else {
    //   await Login().authenticate(username, password).then((response) {
    //     if (response['msg'] == 'success') {
    //       Navigator.of(context).pop();
    //       final jsonData = json.encode(response['data']);
    //       final results = json.decode(jsonData);

    //       print(results);

    //       UserInfoModel userinfomodel = UserInfoModel(
    //           results[0]['employeeid'].toString(),
    //           results[0]['fullname'],
    //           results[0]['position'],
    //           results[0]['contactinfo'],
    //           results[0]['datehired'],
    //           results[0]['usercode'],
    //           results[0]['accesstype'],
    //           results[0]['status'],
    //           results[0]['APK']);

    //       final userinfo = {
    //         'employeeid': results[0]['employeeid'].toString(),
    //         'fullname': results[0]['fullname'],
    //         'position': results[0]['position'],
    //         'contactinfo': results[0]['contactinfo'],
    //         'datehired': results[0]['datehired'],
    //         'usercode': results[0]['usercode'],
    //         'accesstype': results[0]['accesstype'],
    //         'status': results[0]['status'],
    //         'APK': results[0]['APK'],
    //       };

    //       if (Platform.isAndroid) {
    //         Helper().jsonToFileWriteAndroid(userinfo, 'user.json');
    //       }

    //       if (Platform.isWindows) {
    //         Helper().writeJsonToFile(userinfo, 'user.json');
    //       }

    //       _saveRememberedCredentials();

    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => MyDashboard(
    //                   accesstype: userinfomodel.accesstype,
    //                   employeeid: userinfomodel.employeeid,
    //                   fullname: userinfomodel.fullname,
    //                   positiontype: userinfomodel.position,
    //                   logo: branchlogo,
    //                 )),
    //       );
    //     } else {
    //       Navigator.of(context).pop();
    //       showDialog(
    //         context: context,
    //         barrierDismissible: false,
    //         builder: (ctx) => AlertDialog(
    //           title: const Text('Access'),
    //           content: const Text('Incorrect username and password'),
    //           actions: [
    //             TextButton(
    //               onPressed: () => Navigator.pop(ctx),
    //               child: const Text('OK'),
    //             ),
    //           ],
    //         ),
    //       );
    //     }
    //   });
    // }
  }

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
      print(obscureText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 200,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: SizedBox(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: ClipOval(
                          child: SvgPicture.string(branchlogo),
                        ))),
                Padding(
                  padding: const EdgeInsets.all(40),
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
                          obscureText: obscureText,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: togglePasswordVisibility,
                                icon: Icon(obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              )),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onLongPress: () {
                            _login();
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 80),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary),
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
      ),
    );
  }
}
