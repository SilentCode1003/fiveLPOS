import 'dart:convert';
import 'dart:io';

import 'package:fivelPOS/api/employees.dart';
import 'package:fivelPOS/api/payment.dart';
import 'package:fivelPOS/api/posshiftlog.dart';
import 'package:fivelPOS/api/promo.dart';
import 'package:fivelPOS/api/salesdetails.dart';
import 'package:fivelPOS/model/customert.dart';
import 'package:fivelPOS/model/discountdetail.dart';
import 'package:fivelPOS/model/items.dart';
import 'package:fivelPOS/model/refund.dart';
import 'package:fivelPOS/model/sales.dart';
import 'package:fivelPOS/model/splitsales.dart';
import 'package:fivelPOS/repository/dbhelper.dart';

import '../api/category.dart';
import '../api/discount.dart';
import '../api/productprice.dart';
import '../api/transaction.dart';
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
            _databaseHelper.deleteItem('category');
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
        print(data);
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
                  'quantity': data['quantity'],
                });
                if (Platform.isAndroid) {
                  _databaseHelper.deleteItem('productprice');
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
          _databaseHelper.deleteItem('discount');
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
          _databaseHelper.deleteItem('promo');
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

  Future<void> getPayments() async {
    final results = await PaymentAPI().getPayment();
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> jsonToWrite = [];

    if (results['msg'] == 'success') {
      for (var data in json.decode(jsonData)) {
        print(data);

        jsonToWrite.add({
          'paymentname': data['paymentname'],
        });

        if (Platform.isAndroid) {
          _databaseHelper.deleteItem('payments');
          _databaseHelper.insertItem({
            'paymentname': data['paymentname'],
          }, 'payments');
        }
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'payments.json');
      }

      if (Platform.isAndroid) {
        print('android');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'payments.json');
      }
    } else {
      print(results['msg']);
    }
  }

  Future<void> getEmployees() async {
    final results = await EmployeesAPI().getEmployees();
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> jsonToWrite = [];

    if (results['msg'] == 'success') {
      for (var data in json.decode(jsonData)) {
        print(data);

        jsonToWrite.add({
          'fullname': data['fullname'],
        });

        if (Platform.isAndroid) {
          _databaseHelper.deleteItem('employees');
          _databaseHelper.insertItem({
            'fullname': data['fullname'],
          }, 'employees');
        }
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'employees.json');
      }

      if (Platform.isAndroid) {
        print('android');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'employees.json');
      }
    } else {
      print(results['msg']);
    }
  }

  Future<void> getDetailID() async {
    Map<String, dynamic> pos = {};
    String posid = '';
    if (Platform.isWindows) {
      pos = await Helper().readJsonToFile('pos.json');

      posid = pos['posid'].toString();
      print(posid);
    }

    if (Platform.isAndroid) {
      pos = await Helper().jsonToFileReadAndroid('pos.json');

      posid = pos['posid'].toString();
    }
    final results = await SalesDetails().getdetailid(posid);
    List<Map<String, dynamic>> jsonToWrite = [];

    if (results['msg'] == 'success') {
      jsonToWrite.add({
        'detailid': results['data'],
      });

      if (Platform.isAndroid) {
        _databaseHelper.deleteItem('posdetailid');
        _databaseHelper.insertItem({
          'detailid': results['data'],
        }, 'posdetailid');
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'posdetailid.json');
      }

      if (Platform.isAndroid) {
        print('android');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'posdetailid.json');
      }
    } else {
      print(results['msg']);
    }
  }

  Future<void> getPosShift() async {
    Map<String, dynamic> pos = {};
    String posid = '';
    if (Platform.isWindows) {
      pos = await Helper().readJsonToFile('pos.json');

      posid = pos['posid'].toString();
      print(posid);
    }

    if (Platform.isAndroid) {
      pos = await Helper().jsonToFileReadAndroid('pos.json');

      posid = pos['posid'].toString();
    }

    final results = await POSShiftLogAPI().getPOSShift(posid);
    final jsonData = json.encode(results['data']);
    List<Map<String, dynamic>> jsonToWrite = [];

    print(jsonData);
    if (results['msg'] == 'success') {
      for (var data in json.decode(jsonData)) {
        print(data);
        jsonToWrite.add({
          'posid': data['posid'],
          'date': data['date'],
          'shift': data['shift'],
          'status': data['status'],
        });

        if (Platform.isAndroid) {
          _databaseHelper.deleteItem('posshift');
          _databaseHelper.insertItem({
            'posid': data['posid'],
            'date': data['date'],
            'shift': data['shift'],
            'status': data['status'],
          }, 'posshift');
        }
      }

      if (Platform.isWindows) {
        print('windows');
        Helper().writeListJsonToFile(jsonToWrite, 'posshift.json');
      }

      if (Platform.isAndroid) {
        print('android');
        Helper().jsonListToFileWriteAndroid(jsonToWrite, 'posshift.json');
      }
    } else {
      print(results['msg']);
    }
  }

  Future<void> syncSales() async {
    List<dynamic> sales = [];
    String posid = '';
    if (Platform.isWindows) {
      sales = await Helper().readJsonListToFile('sales.json');
    }

    if (Platform.isAndroid) {
      sales = await Helper().jsonListToFileReadAndroid('sales.json');
    }

    // print(sales);

    if (sales.isEmpty) {
      return;
    }

    for (var s in sales) {
      SalesModel ss = SalesModel.fromJson(s);
      List<Map<String, dynamic>> items = [];
      List<Map<String, dynamic>> discount = [];

      print('Syncing: OR# ${ss.detaildid}...');

      for (ItemsModel item in ss.items) {
        items.add({
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'stocks': item.stocks,
        });
      }

      if (ss.discountdetail.isNotEmpty) {
        for (DiscountDetailModel discountdetail in ss.discountdetail) {
          List<CustomerModel> customerinfo = discountdetail.customerinfo;
          for (CustomerModel customer in customerinfo) {
            discount.add({
              'detailid': discountdetail.detailid,
              'discountid': discountdetail.discountid,
              'customerinfo': [
                {'fullname': customer.fullname, 'id': customer.id}
              ],
              'amount': discountdetail.amount,
            });
          }
        }
        print('DISCOUNT: $discount');
      }

      print('ITEMS: $items');

      final results = await POSTransaction().sending(
          ss.detaildid,
          ss.date,
          ss.posid,
          ss.shift,
          ss.paymenttype,
          ss.referenceid,
          ss.paymentname,
          jsonEncode(items),
          ss.total,
          ss.cashier,
          ss.cash,
          ss.ecash,
          ss.branch,
          jsonEncode(discount));

      final jsonData = json.encode(results['data']);
      if (results['msg'] == 'success') {
        print('Success: OR# ${ss.detaildid} Synced');
      } else {
        print(results['msg']);
      }
    }

    List<Map<String, dynamic>> jsonToWrite = [];

    // if (Platform.isAndroid) {
    //   _databaseHelper.deleteItem('sales');
    // }

    if (Platform.isWindows) {
      print('windows');
      Helper().writeListJsonToFile(jsonToWrite, 'sales.json');
    }

    if (Platform.isAndroid) {
      print('android');
      Helper().jsonListToFileWriteAndroid(jsonToWrite, 'sales.json');
    }
  }

  Future<void> syncSplitSales() async {
    List<dynamic> sales = [];
    String posid = '';
    if (Platform.isWindows) {
      sales = await Helper().readJsonListToFile('splitpayment.json');
    }

    if (Platform.isAndroid) {
      sales = await Helper().jsonListToFileReadAndroid('splitpayment.json');
    }

    print(sales);

    if (sales.isEmpty) {
      return;
    }

    for (var s in sales) {
      SplitSalesModel ss = SplitSalesModel.fromJson(s);
      List<Map<String, dynamic>> items = [];
      List<Map<String, dynamic>> discount = [];

      print('Syncing: OR# ${ss.detaildid}...');

      for (ItemsModel item in ss.items) {
        items.add({
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'stocks': item.stocks,
        });
      }

      if (ss.discountdetails.isNotEmpty) {
        for (DiscountDetailModel discountdetail in ss.discountdetails) {
          List<CustomerModel> customerinfo = discountdetail.customerinfo;
          for (CustomerModel customer in customerinfo) {
            discount.add({
              'detailid': discountdetail.detailid,
              'discountid': discountdetail.discountid,
              'customerinfo': [
                {'fullname': customer.fullname, 'id': customer.id}
              ],
              'amount': discountdetail.amount,
            });
          }
        }
        print('DISCOUNT: $discount');
      }

      print('ITEMS: $items');

      final results = await POSTransaction().splitpayment(
          ss.detaildid,
          ss.date,
          ss.posid,
          ss.shift,
          jsonEncode(items),
          ss.staff,
          ss.firstpayment,
          ss.secondpayment,
          ss.firstpaymenttype,
          ss.secondpaymenttype,
          ss.branchid,
          ss.firstpatmentreference,
          ss.secondpaymentreference,
          jsonEncode(discount),
          ss.total);

      final jsonData = json.encode(results['data']);
      if (results['msg'] == 'success') {
        print('Success: OR# ${ss.detaildid} Synced');
      } else {
        print(results['msg']);
      }
    }

    List<Map<String, dynamic>> jsonToWrite = [];

    // if (Platform.isAndroid) {
    //   _databaseHelper.deleteItem('sales');
    // }

    if (Platform.isWindows) {
      print('windows');
      Helper().writeListJsonToFile(jsonToWrite, 'splitpayment.json');
    }

    if (Platform.isAndroid) {
      print('android');
      Helper().jsonListToFileWriteAndroid(jsonToWrite, 'splitpayment.json');
    }
  }

  Future<void> syncRefund() async {
    List<dynamic> sales = [];
    String posid = '';
    if (Platform.isWindows) {
      sales = await Helper().readJsonListToFile('refund.json');
    }

    if (Platform.isAndroid) {
      sales = await Helper().jsonListToFileReadAndroid('refund.json');
    }

    print(sales);

    if (sales.isEmpty) {
      return;
    }

    for (var s in sales) {
      RefundModel ss = RefundModel.fromJson(s);
      print('Syncing: OR# ${ss.detaildid} for REFUND...');

      final results =
          await SalesDetails().refund(ss.detaildid, ss.reason, ss.cashier);

      final jsonData = json.encode(results['data']);
      if (results['msg'] == 'success') {
        print('Success: OR# ${ss.detaildid} Synced');
      } else {
        print(results['msg']);
      }
    }

    List<Map<String, dynamic>> jsonToWrite = [];

    // if (Platform.isAndroid) {
    //   _databaseHelper.deleteItem('sales');
    // }

    if (Platform.isWindows) {
      print('windows');
      Helper().writeListJsonToFile(jsonToWrite, 'refund.json');
    }

    if (Platform.isAndroid) {
      print('android');
      Helper().jsonListToFileWriteAndroid(jsonToWrite, 'refund.json');
    }
  }
}
