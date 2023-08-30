import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos2/api/branch.dart';
import 'package:pos2/components/circularprogressbar.dart';
import 'package:pos2/components/loadingspinner.dart';
import 'package:pos2/components/loginpage.dart';
import 'package:pos2/repository/dbhelper.dart';
import 'package:pos2/api/posconfig.dart';
import 'package:sqflite/sqlite_api.dart';

class PosConfig extends StatefulWidget {
  const PosConfig({super.key});

  @override
  State<PosConfig> createState() => _PosConfigState();
}

class _PosConfigState extends State<PosConfig> {
  final TextEditingController _posidController = TextEditingController();
  final TextEditingController _branchidController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();
  @override
  void initState() {
    _check();
    super.initState();
  }

  Future<void> _check() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');

    if (posconfig.isNotEmpty) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      showDialog(
        context: context,
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

  Future<void> _sync() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CircularProgressBar(
            status: 'Loading...',
          );
        });

    await _getbranch();
     
     showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CircularProgressBar(
              status: 'Branch Done Syncing...',
            );
          });

    await _getposconfig();
   
  }

  Future<void> _getposconfig() async {
    Database db = await dbHelper.database;
    String posid = _posidController.text;
    final result = await PosConfigAPI().posconfig(posid);
    final jsonData = json.encode(result['data']);

    if (jsonData.length != 2) {
      for (var data in json.decode(jsonData)) {
        await dbHelper.insertItem({
          "posid": data['posid'],
          "posname": data['posname'],
          "serial": data['serial'],
          "min": data['min'],
          "ptu": data['ptu'],
        }, 'pos');
      }

      List<Map<String, dynamic>> posconfig = await db.query('pos');
      for (var pos in posconfig) {
        // String name = pos['posid'];
        print('${pos['posid']} ${pos['posname']}');
        // Process data
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: Text('POS ${posid} sync successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Not Found'),
          content: const Text('POS ID has no confuguration'),
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

  Future<void> _getbranch() async {
    Database db = await dbHelper.database;
    String branchid = _branchidController.text;
    final results = await BranchAPI().getBranch(branchid);
    final jsonData = json.encode(results['data']);

    if (jsonData.length != 2) {
      for (var data in json.decode(jsonData)) {
        await dbHelper.insertItem({
          "branchid": data['branchid'],
          "branchname": data['branchname'],
          "tin": data['tin'],
          "address": data['address'],
          "logo": data['logo'],
        }, 'branch');
      }

      List<Map<String, dynamic>> branchconfig = await db.query('branch');
      for (var branch in branchconfig) {
        print('${branch['branchname']} ${branch['tin']} ${branch['address']}');
      }

       Navigator.pop(context);
    } else {
      showDialog(
        context: context,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextField(
              controller: _branchidController,
              decoration: const InputDecoration(labelText: "BRANCH ID"),
            ),
            TextField(
              controller: _posidController,
              decoration: const InputDecoration(labelText: "POS ID"),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _sync();
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 80)),
              child: const Text("SYNC"),
            )
          ]),
        ),
      ),
    );
  }
}
