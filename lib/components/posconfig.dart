// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fivelPOS/repository/sync.dart';
import 'package:sqflite/sqflite.dart';

import 'package:fivelPOS/repository/customerhelper.dart';
import 'package:flutter/material.dart';
import 'package:fivelPOS/api/branch.dart';
import 'package:fivelPOS/components/circularprogressbar.dart';
import 'package:fivelPOS/components/loginpage.dart';
import 'package:fivelPOS/repository/dbhelper.dart';
import 'package:fivelPOS/api/posconfig.dart';
import 'package:path_provider/path_provider.dart';

class PosConfig extends StatefulWidget {
  const PosConfig({super.key});

  @override
  State<PosConfig> createState() => _PosConfigState();
}

class _PosConfigState extends State<PosConfig> {
  final TextEditingController _posidController = TextEditingController();
  final TextEditingController _branchidController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _emailPasswordController =
      TextEditingController();
  final TextEditingController _emailServerController = TextEditingController();

  final TextEditingController _serverController = TextEditingController();

  String branchlogo = '';

  final String _windowSize = 'Unknown';

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final SyncToDatabase _syncToDatabase = SyncToDatabase.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _check();
    });
  }

  Future<void> _check() async {
    // List<Map<String, dynamic>> posconfig = await db.query('pos');
    // List<Map<String, dynamic>> branchconfig = await db.query('branch');
    // List<Map<String, dynamic>> emailconfig = await db.query('email');

    if (Platform.isAndroid) {
      Database db = await _databaseHelper.database;

      //config files
      await createJsonFile('pos.json');
      await createJsonFile('branch.json');
      await createJsonFile('email.json');
      await createJsonFile('printer.json');
      await createJsonFile('server.json');
      await createJsonFile('networkstatus.json');
      await createJsonFile('user.json');
      //database data
      await createJsonFile('category.json');
      await createJsonFile('productprice.json');
      await createJsonFile('discounts.json');
      await createJsonFile('promo.json');
      await createJsonFile('payments.json');
      await createJsonFile('employees.json');
      await createJsonFile('posdetailid.json');
      await createJsonFile('posshift.json');
      await createJsonFile('sales.json');
      await createJsonFile('splitpayment.json');
      await createJsonFile('refund.json');

      Map<String, dynamic> pos =
          await Helper().jsonToFileReadAndroid('pos.json');
      Map<String, dynamic> branch =
          await Helper().jsonToFileReadAndroid('branch.json');
      Map<String, dynamic> email =
          await Helper().jsonToFileReadAndroid('email.json');
      Map<String, dynamic> printer =
          await Helper().jsonToFileReadAndroid('printer.json');
      Map<String, dynamic> server =
          await Helper().jsonToFileReadAndroid('server.json');

      _branchidController.text = branch['branchid'];
      _posidController.text = pos['posid'].toString();
      _serverController.text = server['uri'];

      if (pos.isNotEmpty && branch.isNotEmpty) {
        // List<Map<String, dynamic>> branchconfig = await db.query('branch');
        // for (var branch in branchconfig) {
        setState(() {
          branchlogo = branch['logo'];
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                        logo: branchlogo,
                      )));
        });
        //}
      } else {
        if (pos.isNotEmpty) {
          //for (var pos in posconfig) {
          // String name = pos['posid'];
          print('${pos['posid']}');
          setState(() {
            _posidController.text = pos['posid'].toString();
          });
          // Process data
          //}
        }

        if (branch.isNotEmpty) {
          //for (var branch in branchconfig) {
          // String name = pos['posid'];
          print('${branch['branchid']}');

          setState(() {
            branchlogo = branch['logo'];
            _branchidController.text = branch['branchid'];
          });
          // Process data
          // }
        }

        // if (email.isNotEmpty) {
        //   //for (var email in emailconfig) {
        //   // String name = pos['posid'];
        //   print(
        //       '${email['emailaddress']} ${email['emailpassword']} ${email['emailserver']}');

        //   setState(() {
        //     _emailAddressController.text = email['emailaddress'];
        //     _emailPasswordController.text = email['emailpassword'];
        //     _emailServerController.text = email['emailserver'];
        //   });
        //   // Process data
        //   //}
        // }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Not yet configured'),
            content: const Text('Please enter POS ID and SYNC to Server'),
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

    if (Platform.isWindows) {
      Map<String, dynamic> pos = await Helper().readJsonToFile('pos.json');
      Map<String, dynamic> branch =
          await Helper().readJsonToFile('branch.json');
      Map<String, dynamic> server =
          await Helper().readJsonToFile('server.json');

      if (pos.isNotEmpty && branch.isNotEmpty) {
        // List<Map<String, dynamic>> branchconfig = await db.query('branch');
        // for (var branch in branchconfig) {
        _branchidController.text = branch['branchid'];
        _posidController.text = pos['posid'].toString();
        _serverController.text = server['uri'];
        setState(() {
          branchlogo = branch['logo'];
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                        logo: branchlogo,
                      )));
        });
        //}
      } else {
        if (pos.isNotEmpty) {
          //for (var pos in posconfig) {
          // String name = pos['posid'];
          print('${pos['posid']}');
          setState(() {
            _posidController.text = pos['posid'].toString();
          });
          // Process data
          //}
        }

        if (branch.isNotEmpty) {
          //for (var branch in branchconfig) {
          // String name = pos['posid'];
          print('${branch['branchid']}');

          setState(() {
            branchlogo = branch['logo'];
            _branchidController.text = branch['branchid'];
          });
          // Process data
          // }
        }

        // if (email.isNotEmpty) {
        //   //for (var email in emailconfig) {
        //   // String name = pos['posid'];
        //   print(
        //       '${email['emailaddress']} ${email['emailpassword']} ${email['emailserver']}');

        //   setState(() {
        //     _emailAddressController.text = email['emailaddress'];
        //     _emailPasswordController.text = email['emailpassword'];
        //     _emailServerController.text = email['emailserver'];
        //   });
        //   // Process data
        //   //}
        // }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Not yet configured'),
            content: const Text('Please enter POS ID and SYNC to Server'),
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

    final isOnline = await Helper().hasInternetConnection();

    if (isOnline) {
      showDialog(
          context: context,
          builder: (context) {
            return CircularProgressBar(
              status: 'Start Syncing...',
              module: 'Categories',
            );
          });
      Future.delayed(const Duration(seconds: 1), () async {
        await _syncToDatabase.getcategory().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Category',
                  module: 'Product Price',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 2), () async {
        await _syncToDatabase.getProductPrice().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Product Price',
                  module: 'Discounts',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: const Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
      });

      Future.delayed(const Duration(seconds: 3), () async {
        await _syncToDatabase.getDiscount().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Discounts',
                  module: 'Promos',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 4), () async {
        await _syncToDatabase.getPromo().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Promos',
                  module: 'Payments',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 5), () async {
        await _syncToDatabase.getPayments().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Payments',
                  module: 'Employees',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 6), () async {
        await _syncToDatabase.getEmployees().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Employees',
                  module: 'Detail ID',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 7), () async {
        await _syncToDatabase.getDetailID().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Detail ID',
                  module: 'POS Shift',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 6), () async {
        await _syncToDatabase.getPosShift().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done POS Shift',
                  module: 'Sales',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 9), () async {
        await _syncToDatabase.syncSales().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Sales',
                  module: 'Split Sales',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 10), () async {
        await _syncToDatabase.syncSplitSales().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done Split Sales',
                  module: 'Refunds',
                );
              });
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });

      Future.delayed(const Duration(seconds: 11), () async {
        await _syncToDatabase.syncRefund().then((value) {
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (context) {
                return CircularProgressBar(
                  status: 'Done POS Refund',
                  module: '',
                );
              });

          Navigator.pop(context);
        });
      }).catchError((e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                      'Please check your network or contact administrator'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ));
        return;
      });
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
                content: Text('Offline Mode'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK')),
                  ElevatedButton(
                      onPressed: () {
                        _check();
                      },
                      child: const Text('Retry'))
                ],
              ));
    }
  }

  Future<void> _sync() async {
    String branch = '';
    String pos = '';

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CircularProgressBar(
            status: 'Syncing...',
            module: '',
          );
        });

    Map<String, dynamic> serverconfig = {};
    serverconfig = {'uri': _serverController.text};

    if (Platform.isWindows) {
      print('windows');
      Helper().writeJsonToFile(serverconfig, 'server.json');
    }

    if (Platform.isAndroid) {
      print('android');
      Helper().jsonToFileWriteAndroid(serverconfig, 'server.json');
    }

    await _getbranch().then((value) async {
      branch = value;
      showDialog(
          context: context,
          builder: (context) => CircularProgressBar(
                status: 'Done Syncing Branch',
                module: 'POS Configuration...',
              ));
      await _getposconfig().then((value) {
        pos = value;
        showDialog(
            context: context,
            builder: (context) => CircularProgressBar(
                  status: 'Done Syncing POS Configuration',
                  module: '',
                ));

        if (branch == '' || pos == '') {
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Success'),
              content: Text('POS ${_posidController.text} sync successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);

                    _check();

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => LoginPage(
                    //             logo: branchlogo,
                    //           )),
                    // );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  Future<String> _getposconfig() async {
    try {
      // Database db = await dbHelper.database;
      String posid = _posidController.text;
      final result = await PosConfigAPI().posconfig(posid);
      final jsonData = json.encode(result['data']);

      // List<Map<String, dynamic>> posconfig = await db.query('pos');

      // if (posconfig.isNotEmpty) {
      //   for (var pos in posconfig) {
      //     // String name = pos['posid'];
      //     print('${pos['posid']}');
      //     Helper().writeJsonToFile(pos, 'pos.json');

      //     dbHelper.updateItem(pos, 'pos', 'posid=?', pos['posid']);
      //     // Process data
      //   }
      //   Navigator.pop(context);
      //   return 'success';
      // } else {
      if (jsonData.length != 2) {
        for (var data in json.decode(jsonData)) {
          if (Platform.isWindows) {
            Helper().writeJsonToFile(data, 'pos.json');
          }
          if (Platform.isAndroid) {
            Helper().jsonToFileWriteAndroid(data, 'pos.json');
          }
          // await dbHelper.insertItem({
          //   'posid': data['posid'],
          //   'posname': data['posname'],
          //   'serial': data['serial'],
          //   'min': data['min'],
          //   'ptu': data['ptu'],
          // }, 'pos');
        }

        // List<Map<String, dynamic>> posconfig = await db.query('pos');
        // for (var pos in posconfig) {
        //   Helper().writeJsonToFile(pos, 'pos.json');
        //   String name = pos['posid'];
        //   print('${pos['posid']} ${pos['posname']}');
        //   Process data
        // }

        Navigator.pop(context);

        return 'success';
      } else {
        Navigator.of(context).pop();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Not Found'),
            content: const Text('POS ID has no confuguration'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        return 'POS ID has no confuguration';
      }
      // }
    } catch (e) {
      return 'Please check your network or contact administrator';
    }
  }

  Future<String> _getbranch() async {
    try {
      //Database db = await dbHelper.database;
      String branchid = _branchidController.text;
      final results = await BranchAPI().getBranch(branchid);
      final jsonData = json.encode(results['data']);
      //List<Map<String, dynamic>> branchconfig = await db.query('branch');

      // if (branchconfig.isNotEmpty) {
      //   for (var branch in branchconfig) {
      //     // String name = pos['posid'];
      //     print('${branch['posid']}');
      //     Helper().writeJsonToFile(branch, 'branch.json');

      //     dbHelper.updateItem(
      //         branch, 'branch', 'branchid=?', branch['branchid']);
      //     // Process data
      //   }
      //   Navigator.pop(context);
      //   return 'success';
      // } else {
      if (jsonData.length != 2) {
        for (var data in json.decode(jsonData)) {
          // await dbHelper.insertItem({
          //   'branchid': data['branchid'],
          //   'branchname': data['branchname'],
          //   'tin': data['tin'],
          //   'address': data['address'],
          //   'logo': data['logo'],
          // }, 'branch');
          if (Platform.isWindows) {
            print('windows');
            Helper().writeJsonToFile(data, 'branch.json');
          }

          if (Platform.isAndroid) {
            print('android');
            Helper().jsonToFileWriteAndroid(data, 'branch.json');
          }

          branchlogo = data['logo'];
        }

        //List<Map<String, dynamic>> branchconfig = await db.query('branch');
        // for (var branch in branchconfig) {
        //   Helper().writeJsonToFile(branch, 'branch.json');
        //   print(
        //       '${branch['branchname']} ${branch['tin']} ${branch['address']}');
        // }
        Navigator.pop(context);
        return 'success';
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Not Found'),
            content: const Text('Branch ID has no confuguration'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        return 'Branch ID has no confuguration';
      }
      //}
    } catch (e) {
      return 'Please check your network or contact administrator';
    }
  }

  Future<String> _emailconfig() async {
    try {
      //Database db = await dbHelper.database;
      String emailaddress = _emailAddressController.text;
      String emailpassword = _emailPasswordController.text;
      String emailserver = _emailServerController.text;

      //List<Map<String, dynamic>> emailconfig = await db.query('email');

      // if (emailconfig.isNotEmpty) {
      //   for (var email in emailconfig) {
      //     // String name = pos['posid'];
      //     print('${email['posid']}');
      //     Helper().writeJsonToFile(email, 'email.json');

      //     dbHelper.updateItem(
      //         email, 'email', 'emailaddress=?', email['emailaddress']);
      //     // Process data
      //   }
      //   Navigator.pop(context);
      //   return 'success';
      // } else {
      // await dbHelper.insertItem({
      //   'emailaddress': emailaddress,
      //   'emailpassword': emailpassword,
      //   'emailserver': emailserver,
      // }, 'email');

      if (Platform.isAndroid) {
        Helper().jsonToFileWriteAndroid({
          'emailaddress': emailaddress,
          'emailpassword': emailpassword,
          'emailserver': emailserver,
        }, 'email.json');
      }

      if (Platform.isWindows) {
        Helper().writeJsonToFile({
          'emailaddress': emailaddress,
          'emailpassword': emailpassword,
          'emailserver': emailserver,
        }, 'email.json');
      }

      //List<Map<String, dynamic>> emailconfig = await db.query('email');
      // for (var email in emailconfig) {
      //   Helper().writeJsonToFile(email, 'email.json');
      //   print(
      //       '${email['emailaddress']} ${email['emailpassword']} ${email['emailserver']}');
      // }
      Navigator.pop(context);
      return 'success';
      //}
    } catch (e) {
      return 'Please check your network or contact administrator';
    }
  }

  Future<void> createJsonFile(filename) async {
    try {
      // Get the current working

      final directory = await getApplicationDocumentsDirectory();

      // Specify the file name and path
      final filePath = '${directory.path}/$filename';

      // Create a File object
      final File file = File(filePath);

      if (file.existsSync()) {
        return;
      }

      // Create a Map (or any other data structure) to convert to JSON
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
          "employeeid": "",
          "fullname": "",
          "position": 0,
          "contactinfo": "",
          "datehired": "",
          "usercode": 0,
          "accesstype": 0,
          "status": "",
          "APK":
              "e7e21a794cec6b17c095679a3410759c952a6a2cdd4870611647110d6a8a6c431a4d587cf12940fbd33b359f81a21e948c4ef3d4ff4808a9d888dc8775dc2b53e9678cc713acaf0361efdc1e8cfc735cb5f3bb30029da15d398d6abf3b9122a563dc640277c643efb5e5191368975b86a85f36fae4814adf740c5cc32fa6d1c747b80381f10e4f5b058f45a6b9b4f94bcf4406af839511b82bc0bd6404cf582d0f8e8aa54c99c813e7bd7067954320745aed8e8eed368b910eb15ebf82533369852d5f6dd779dd3c18bbfc6e7ecb68423528249078b901741e9e86add43afee07c60386624ba60e6479ac9fc3685eccb92feadba10206f81d1ad1a5aa5f9e535ff654ef512e679cfd87ec4a161651eb58941ccd74209201402f3a792fea0f3d9953033191294515d43be2eeffb039882"
        };
      }

      // Convert the Map to a JSON string
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'POS Configuration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: _branchidController,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Branch ID',
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'Branch ID',
                    hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: _posidController,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'POS ID',
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'POS ID',
                    hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: _serverController,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Server',
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    hintText: 'https://example.com/',
                    hintStyle: const TextStyle(fontWeight: FontWeight.normal),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _sync();
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 80)),
                  child: const Text('SYNC'),
                ),
              )
            ]),
      ),
    );
  }
}
