import 'dart:convert';
import 'dart:io';

import 'package:fivelPOS/api/promo.dart';
import 'package:fivelPOS/repository/dbhelper.dart';

import '../api/category.dart';
import '../api/discount.dart';
import '../api/productprice.dart';
import 'customerhelper.dart';

class SyncToDatabase {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static final SyncToDatabase instance = SyncToDatabase._contructor();

  SyncToDatabase._contructor();

  Future<void> getcategory() async {
    final results = await CategoryAPI().getCategory();
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> jsonToWrite = [];

    if (results['msg'] == 'success') {
      for (var data in json.decode(jsonData)) {
        if (data['categoryname'] == 'Material') {
        } else {
          jsonToWrite.add({
            'categorycode': data['categorycode'],
            'categoryname': data['categoryname'],
            'status': data['status'],
            'createdby': data['createdby'],
            'createddate': data['createddate']
          });
          if (Platform.isAndroid) {
            _databaseHelper.insertItem({
              'categorycode': data['categorycode'],
              'categoryname': data['categoryname'],
              'status': data['status'],
              'createdby': data['createdby'],
              'createddate': data['createddate']
            }, 'category');
          }
        }
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'category.json');
      }

      if (Platform.isAndroid) {
        print('android');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'category.json');
      }
    } else {
      print(results['msg']);
    }
  }

  Future<void> getProductPrice() async {
    final categoryResults = await CategoryAPI().getCategory();
    final jsonDataCategory = json.encode(categoryResults['data']);
    Map<String, dynamic> branch = {};
    String branchid = '';
    List<Map<String, dynamic>> jsonToWrite = [];

    if (Platform.isWindows) {
      branch = await Helper().readJsonToFile('branch.json');

      branchid = branch['branchid'];
    }

    if (Platform.isAndroid) {
      branch = await Helper().jsonToFileReadAndroid('branch.json');

      branchid = branch['branchid'];
    }

    if (categoryResults['msg'] == 'success') {
      for (var data in json.decode(jsonDataCategory)) {
        if (data['categoryname'] == 'Material') {
        } else {
          final results = await ProductPrice()
              .getcategoryitems('${data['categorycode']}', branchid);

          final jsonData = json.decode(results['data']);
          if (results['msg'] == 'success') {
            for (var data in jsonData) {
              if (data['categoryname'] == 'Material') {
              } else {
                jsonToWrite.add({
                  'productid': data['productid'],
                  'description': data['description'],
                  'barcode': data['barcode'],
                  'price': data['price'],
                  'category': data['category'],
                  'quantity': data['quantity']
                });
                if (Platform.isAndroid) {
                  _databaseHelper.insertItem({
                    'productid': data['productid'],
                    'description': data['description'],
                    'barcode': data['barcode'],
                    'price': data['price'],
                    'category': data['category'],
                    'quantity': data['quantity']
                  }, 'productprice');
                }
              }
            }
          } else {
            print(results['msg']);
          }
        }
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'productprice.json');
      }

      if (Platform.isAndroid) {
        print('windows');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'productprice.json');
      }
    } else {
      print(categoryResults['msg']);
    }
  }

  Future<void> getDiscount() async {
    final results = await DiscountAPI().getDiscount();
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> jsonToWrite = [];

    if (results['msg'] == 'success') {
      for (var data in json.decode(jsonData)) {
        print(data);

        jsonToWrite.add({
          'discountid': data['discountid'],
          'discountname': data['name'],
          'description': data['description'],
          'rate': data['rate'],
          'status': data['status'],
          'createdby': data['createdby'],
          'createddate': data['createddate'],
        });

        if (Platform.isAndroid) {
          _databaseHelper.insertItem({
            'discountid': data['discountid'],
            'discountname': data['name'],
            'description': data['description'],
            'rate': data['rate'],
            'status': data['status'],
            'createdby': data['createdby'],
            'createddate': data['createddate'],
          }, 'discount');
        }
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'discount.json');
      }

      if (Platform.isAndroid) {
        print('windows');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'discount.json');
      }
    } else {
      print(results['msg']);
    }
  }

  Future<void> getPromo() async {
    final results = await PromoAPI().getPromo();
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> jsonToWrite = [];

    if (results['msg'] == 'success') {
      for (var data in json.decode(jsonData)) {
        print(data);

        jsonToWrite.add({
          'promoid': data['promoid'],
          'name': data['name'],
          'description': data['description'],
          'condition': data['condition'],
          'startdate': data['startdate'],
          'enddate': data['enddate'],
          'status': data['status'],
          'createdby': data['createdby'],
          'createddate': data['createddate'],
        });

        if (Platform.isAndroid) {
          _databaseHelper.insertItem({
            'promoid': data['promoid'],
            'name': data['name'],
            'description': data['description'],
            'condition': data['condition'],
            'startdate': data['startdate'],
            'enddate': data['enddate'],
            'status': data['status'],
            'createdby': data['createdby'],
            'createddate': data['createddate'],
          }, 'promo');
        }
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'promo.json');
      }

      if (Platform.isAndroid) {
        print('android');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'promo.json');
      }
    } else {
      print(results['msg']);
    }
  }
}
