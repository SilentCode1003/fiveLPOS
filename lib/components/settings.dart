import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:fivelPOS/api/discount.dart';
import 'package:fivelPOS/api/productprice.dart';
import 'package:fivelPOS/components/loadingspinner.dart';
import 'package:fivelPOS/components/settings/networkprinter.dart';
import 'package:fivelPOS/model/category.dart';
import 'package:fivelPOS/model/discount.dart';
import 'package:fivelPOS/model/productprice.dart';
import 'package:fivelPOS/repository/bluetoothprinter.dart';
import 'package:fivelPOS/repository/dbhelper.dart';
import 'package:fivelPOS/repository/sync.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import '../api/category.dart';
import '../model/promo.dart';
import 'package:fivelPOS/model/branch.dart';
import 'package:fivelPOS/model/email.dart';
import 'package:fivelPOS/model/pos.dart';
import 'package:fivelPOS/model/printer.dart';
import 'package:fivelPOS/repository/customerhelper.dart';
import 'package:fivelPOS/repository/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  final String employeeid;
  final String fullname;
  final int accesstype;
  final int positiontype;
  final String logo;
  const SettingsPage({
    super.key,
    required this.employeeid,
    required this.fullname,
    required this.accesstype,
    required this.positiontype,
    required this.logo,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentPage = 0;
  String emailaddress = '';
  String emailpassword = '';
  String smtp = '';

  String branchid = '';
  String branchname = '';

  int posid = 0;
  String posname = '';
  String serial = '';
  String min = '';
  String ptu = '';
  String status = '';
  String createdby = '';
  String createddate = '';

  // bool _ischange = false;

  // final List<String> _selectPrinterType = [
  //   'Select Type',
  //   'Network',
  //   'Bluetooth',
  // ];

  // PrinterNetworkManager _printer = PrinterNetworkManager('');
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  @override
  void initState() {
    // TODO: implement
    _getemailconfig();
    _getposconfig();
    _getbranchconfig();
    _requestBluetoothPermissions();

    super.initState();
  }

  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      // Permissions granted
    } else {
      // Handle the case when permissions are not granted
      // You may want to show a message to the user and re-request permissions
    }
  }

  Future<void> _getemailconfig() async {
    if (Platform.isWindows) {
      var email = await Helper().readJsonToFile('email.json');

      print(email);
      EmailModel model = EmailModel(
          email['emailaddress'], email['emailpassword'], email['emailserver']);

      setState(() {
        emailaddress = model.emailaddress;
        emailpassword = model.emailpassword;
        smtp = model.emailserver;
      });
    }

    if (Platform.isAndroid) {
      var email = await Helper().jsonToFileReadAndroid('email.json');
      print(email);
      EmailModel model = EmailModel(
          email['emailaddress'], email['emailpassword'], email['emailserver']);

      setState(() {
        emailaddress = model.emailaddress;
        emailpassword = model.emailpassword;
        smtp = model.emailserver;
      });
    }
  }

  Future<void> _getbranchconfig() async {
    if (Platform.isWindows) {
      var branch = await Helper().readJsonToFile('branch.json');

      print(branch);
      BranchModel model =
          BranchModel(branch['branchid'], branch['branchname'], '', '', '');

      setState(() {
        branchid = model.branchid;
        branchname = model.branchname;
      });
    }

    if (Platform.isAndroid) {
      var branch = await Helper().jsonToFileReadAndroid('branch.json');
      print(branch);
      BranchModel model =
          BranchModel(branch['branchid'], branch['branchname'], '', '', '');

      setState(() {
        branchid = model.branchid;
        branchname = model.branchname;
      });
    }
  }

  Future<void> _getposconfig() async {
    if (Platform.isWindows) {
      var pos = await Helper().readJsonToFile('pos.json');

      print(pos);
      POSModel model = POSModel(
          pos['posid'],
          pos['posname'],
          pos['serial'],
          pos['min'],
          pos['ptu'],
          pos['status'],
          pos['createdby'],
          pos['createddate']);

      setState(() {
        posid = model.posid;
        posname = model.posname;
      });
    }

    if (Platform.isAndroid) {
      var pos = await Helper().jsonToFileReadAndroid('pos.json');
      print(pos);
      POSModel model = POSModel(
          pos['posid'],
          pos['posname'],
          pos['serial'],
          pos['min'],
          pos['ptu'],
          pos['status'],
          pos['createdby'],
          pos['createddate']);

      setState(() {
        posid = model.posid;
        posname = model.posname;
      });
    }
  }

  void changePage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(),
        body: SafeArea(
          child: Row(
            children: <Widget>[
              NavigationRail(
                selectedIndex: currentPage,
                groupAlignment: groupAlignment,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                labelType: labelType,
                leading: showLeading
                    ? FloatingActionButton(
                        elevation: 0,
                        onPressed: () {
                          // Add your onPressed code here!
                        },
                        child: const Icon(Icons.add),
                      )
                    : const SizedBox(),
                trailing: showTrailing
                    ? IconButton(
                        onPressed: () {
                          // Add your onPressed code here!
                        },
                        icon: const Icon(Icons.more_horiz_rounded),
                      )
                    : const SizedBox(),
                destinations: const <NavigationRailDestination>[
                  NavigationRailDestination(
                    icon: Icon(Icons.print),
                    selectedIcon: Icon(Icons.print),
                    label: Text('Printers'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.email),
                    selectedIcon: Icon(Icons.email),
                    label: Text('Email'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory),
                    selectedIcon: Icon(Icons.inventory),
                    label: Text('Products'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.discount),
                    selectedIcon: Icon(Icons.discount),
                    label: Text('Promo & Discounts'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.install_desktop),
                    selectedIcon: Icon(Icons.install_desktop),
                    label: Text('Offline Files'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.exit_to_app),
                    selectedIcon: Icon(Icons.exit_to_app),
                    label: Text('Exit'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    switch (currentPage) {
      case 0:
        return const PrinterPage();
      case 1:
        return EmailPage(
          emailaddress: emailaddress,
          emailpassword: emailpassword,
          smtp: smtp,
        );
      case 2:
        return const ProductPage();
      case 3:
        return const DiscountPromoPage();
      case 4:
        return ConfigFiles();
      case 5:
        return AlertDialog(
          title: const Text('Return'),
          content: const Text('Click click button to return.'),
          backgroundColor: Colors.grey,
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Retrun to Dashboard')),
          ],
        );
      default:
        return Container();
    }
  }

  PreferredSizeWidget buildAppBar() {
    switch (currentPage) {
      case 0:
        return AppBar();
      case 1:
        return AppBar();
      case 2:
        return AppBar();
      case 3:
        return AppBar();
      default:
        return AppBar();
    }
  }
}

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: TabBar(
              labelColor: Colors.white,
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.print), text: 'Network Printer'),
                Tab(
                    icon: Icon(Icons.bluetooth_searching_sharp),
                    text: 'Bluetooth Printer')
              ]),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(
              controller: _tabController,
              children: [NetworkPrinterConfig(), Bluetoothprinter()],
            ),
          ),
        ),
      ),
    );
  }
}

class EmailPage extends StatefulWidget {
  final String emailaddress;
  final String emailpassword;
  final String smtp;

  const EmailPage({
    super.key,
    required this.emailaddress,
    required this.emailpassword,
    required this.smtp,
  });

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController _emailaddress = TextEditingController();
  final TextEditingController _emailpassword = TextEditingController();
  final TextEditingController _smtpserver = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailaddress.text = widget.emailaddress;
    _emailpassword.text = widget.emailpassword;
    _smtpserver.text = widget.smtp;
  }

  Future<void> saveEmailConfig(jsnonData) async {
    if (Platform.isWindows) {
      await Helper()
          .writeJsonToFile(jsnonData, 'email.json')
          .then((value) => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Email configuration saved!'),
                  icon: const Icon(Icons.check),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                );
              }));
    }
    if (Platform.isAndroid) {
      await Helper()
          .jsonToFileWriteAndroid(jsnonData, 'email.json')
          .then((value) => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Success'),
                  content: const Text('Email configuration saved!'),
                  icon: const Icon(Icons.check),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                );
              }));
    }
  }

  bool obscureText = true;

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
      print(obscureText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: TextField(
                controller: _emailaddress,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    border: OutlineInputBorder(),
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: TextField(
                controller: _emailpassword,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(obscureText
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: togglePasswordVisibility,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    border: OutlineInputBorder(),
                    hintText: 'Email Password',
                    prefixIcon: Icon(Icons.password)),
                obscureText: obscureText,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: TextField(
                controller: _smtpserver,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'SMTP',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    border: OutlineInputBorder(),
                    hintText: 'SMTP Server',
                    prefixIcon: Icon(Icons.desktop_windows)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: ElevatedButton(
                    onPressed: () {
                      saveEmailConfig({
                        'emailaddress': _emailaddress.text,
                        'emailpassword': _emailpassword.text,
                        'emailserver': _smtpserver.text
                      });
                    },
                    child: const Text(
                      'SAVE',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    )))
          ],
        ),
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  get label => null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductPricePage()));
                  },
                  icon: const Icon(Icons.price_change_rounded),
                  label: const Text('Product Price')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryPage()));
                  },
                  icon: const Icon(Icons.category_sharp),
                  label: const Text(
                    'Category',
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscountPromoPage extends StatelessWidget {
  const DiscountPromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DiscountPage()));
                  },
                  icon: const Icon(Icons.discount),
                  label: const Text('Discounts')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 320,
              height: 60,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PromoPage()));
                  },
                  icon: const Icon(Icons.list),
                  label: const Text(
                    'Promo',
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [],
    );
  }
}

//Sub-page
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getcategory() async {
    showDialog(
        context: context,
        builder: (context) => LoadingSpinner(message: 'Fetching Data...'));
    final results = await CategoryAPI().getCategory();
    final jsonData = json.encode(results['data']);

    if (results['msg'] == 'success') {
      Navigator.pop(context);

      setState(() {
        for (var data in json.decode(jsonData)) {
          if (data['categoryname'] == 'Material') {
          } else {
            if (Platform.isWindows) {
              print('windows');
              Helper().writeJsonToFile(data, 'category.json');
            }

            if (Platform.isAndroid) {
              print('android');
              Helper().jsonToFileWriteAndroid(data, 'category.json');
            }

            _databaseHelper.insertItem({
              'categorycode': data['categorycode'],
              'categoryname': data['categoryname'],
              'status': data['status'],
              'createdby': data['createdby'],
              'createddate': data['createddate']
            }, 'category');
          }
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<List<CategoryModel>> _load() async {
    List<CategoryModel> category = [];
    dynamic data;
    try {
      if (Platform.isWindows) {
        data = await Helper().readJsonListToFile('category.json');
      }
      if (Platform.isAndroid) {
        data = await Helper().jsonListToFileReadAndroid('category.json');
      }

      for (var d in data) {
        category.add(CategoryModel(d['categorycode'], d['categoryname'],
            d['status'], d['createdby'], d['createddate']));
      }

      return category;
    } catch (e) {
      print(e);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'))
              ],
            );
          });

      return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButton: _syncButton(),
        body: _categoryList(),
      ),
    );
  }

  Widget _syncButton() {
    return FloatingActionButton(
      onPressed: () {
        _getcategory();
      },
      child: const Icon(Icons.sync),
    );
  }

  Widget _categoryList() {
    return FutureBuilder<List<CategoryModel>>(
        future: _load(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                CategoryModel category = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Text(
                        category.categorycode.toString(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        category.categoryname,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Date Created: ${category.createddate} Created By: ${category.createdby}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        category.status,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}

class ProductPricePage extends StatefulWidget {
  const ProductPricePage({super.key});

  @override
  State<ProductPricePage> createState() => _ProductPricePageState();
}

class _ProductPricePageState extends State<ProductPricePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> _getProductPrice() async {
    showDialog(
        context: context,
        builder: (context) => LoadingSpinner(message: 'Fetching Data...'));

    Map<String, dynamic> branch = {};
    String branchid = '';

    if (Platform.isWindows) {
      branch = await Helper().readJsonToFile('branch.json');
      setState(() {
        branchid = branch['branchid'];
      });
    }

    if (Platform.isAndroid) {
      branch = await Helper().jsonToFileReadAndroid('branch.json');
      setState(() {
        branchid = branch['branchid'];
      });
    }

    final categoryResults = await CategoryAPI().getCategory();
    final jsonDataCategory = json.encode(categoryResults['data']);

    if (categoryResults['msg'] == 'success') {
      Navigator.pop(context);
      for (var data in json.decode(jsonDataCategory)) {
        print(data);
        if (data['categoryname'] == 'Material') {
        } else {
          showDialog(
              context: context,
              builder: (context) => LoadingSpinner(
                  message: 'Fetching Data of ${data['categorycode']}...'));

          final results = await ProductPrice()
              .getcategoryitems('${data['categorycode']}', branchid);

          final jsonData = json.decode(results['data']);
          print(jsonData);

          if (results['msg'] == 'success') {
            for (var data in jsonData) {
              if (data['categoryname'] == 'Material') {
              } else {
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

            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
        }
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<List<ProductPriceModel>> _load() async {
    List<ProductPriceModel> productprice = [];
    try {
      dynamic data;
      if (Platform.isWindows) {
        data = await Helper().readJsonListToFile('productprice.json');
      }
      if (Platform.isAndroid) {
        data = await Helper().jsonListToFileReadAndroid('productprice.json');
      }

      for (var d in data) {
        productprice.add(ProductPriceModel(
          d['productid'].toString(),
          d['description'] as String,
          d['barcode'] as String,
          d['productimage'] == null ? '' : d['productimage'] as String,
          d['price'].toString(),
          d['category'] as int,
          d['quantity'] as int,
        ));
      }

      return productprice;
    } catch (e) {
      print(e);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'))
              ],
            );
          });

      return productprice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButton: _syncButton(),
        body: _productPriceList(),
      ),
    );
  }

  Widget _syncButton() {
    return FloatingActionButton(
        onPressed: () {
          _getProductPrice();
        },
        child: const Icon(Icons.sync));
  }

  Widget _productPriceList() {
    return FutureBuilder<List<ProductPriceModel>>(
        future: _load(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                ProductPriceModel product = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.add_shopping_cart_rounded, size: 24),
                      title: Text(
                        'Item Name: ${product.description}\nBarcode: ${product.barcode}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Price: ${toCurrencyString(product.price)}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        product.quantity.toString(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> _getDiscount() async {
    showDialog(
        context: context,
        builder: (context) => LoadingSpinner(message: 'Fetching Data...'));

    final results = await DiscountAPI().getDiscount();
    final jsonData = json.encode(results['data']);

    if (results['msg'] == 'success') {
      Navigator.pop(context);
      for (var data in json.decode(jsonData)) {
        print(data);
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
    } else {
      Navigator.pop(context);
    }
  }

  Future<List<DiscountModel>> _load() async {
    List<DiscountModel> discountList = [];

    try {
      dynamic data;
      if (Platform.isWindows) {
        data = await Helper().readJsonListToFile('discount.json');
      }
      if (Platform.isAndroid) {
        data = await Helper().jsonListToFileReadAndroid('discount.json');
      }

      for (var d in data) {
        discountList.add(DiscountModel(
          d['discountid'] as int,
          d['discountname'] as String,
          d['description'] as String,
          d['rate'],
          d['status'] as String,
          d['createdby'] as String,
          d['createddate'] as String,
        ));
      }
      return discountList;
    } catch (e) {
      print(e);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'))
              ],
            );
          });

      return discountList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButton: _syncButton(),
        body: _discountList(),
      ),
    );
  }

  Widget _syncButton() {
    return FloatingActionButton(
      onPressed: () {
        _getDiscount();
      },
      child: const Icon(Icons.sync),
    );
  }

  Widget _discountList() {
    return FutureBuilder<List<DiscountModel>>(
        future: _load(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                DiscountModel discount = snapshot.data![index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Text(
                        'ID: ${discount.discountid}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        'Name: ${discount.discountname}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Rate: ${discount.rate}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        'Status: ${discount.status}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}

class PromoPage extends StatefulWidget {
  const PromoPage({super.key});

  @override
  State<PromoPage> createState() => _PromoPageState();
}

class _PromoPageState extends State<PromoPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> _getPromo() async {}

  Future<List<PromoModel>> _load() async {
    List<PromoModel> promoList = [];

    try {
      dynamic data;
      if (Platform.isWindows) {
        data = await Helper().readJsonListToFile('promo.json');
      }
      if (Platform.isAndroid) {
        data = await Helper().jsonListToFileReadAndroid('promo.json');
      }

      print(data);

      for (var d in data) {
        promoList.add(PromoModel(
          d['promoid'] as int,
          d['name'] as String,
          d['description'] as String,
          d['condition'] as String,
          d['startdate'] as String,
          d['enddate'] as String,
          d['status'] as String,
          d['createdby'] as String,
          d['createddate'] as String,
        ));
      }

      return promoList;
    } catch (e) {
      print(e);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('$e'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'))
              ],
            );
          });

      return promoList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        floatingActionButton: _syncButton(),
        body: _promoList(),
      ),
    );
  }

  Widget _syncButton() {
    return FloatingActionButton(
      onPressed: () {
        _getPromo();
      },
      child: const Icon(Icons.sync),
    );
  }

  Widget _promoList() {
    return FutureBuilder<List<PromoModel>>(
        future: _load(),
        builder: (context, snapshot) {
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                PromoModel promo = snapshot.data![index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Text(
                        'ID: ${promo.promoid}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        'Name: ${promo.name}\nDescription: ${promo.description}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Condition: ${promo.condition}\nStart Date:${promo.startdate}\nEnd Date:${promo.enddate}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        'Status: ${promo.status}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}

class ConfigFiles extends StatefulWidget {
  const ConfigFiles({super.key});

  @override
  State<ConfigFiles> createState() => _ConfigFilesState();
}

class _ConfigFilesState extends State<ConfigFiles> {
  Future<void> _syncAndReset() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return LoadingSpinner(message: 'Loading...');
          });

      if (Platform.isAndroid) {
        await Helper().resetJsonFileArrayAndroid('sales.json');
      }

      if (Platform.isWindows) {
        await Helper().resetJsonFileArray('sales.json');
      }

      Navigator.pop(context);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Data has been reset.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          });
    } catch (e) {
      print(e);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Please inform administrator. Thank you! $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        height: 70,
        width: 240,
        child: ElevatedButton(
          onPressed: () async {
            await _syncAndReset();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text(
            'SYNC AND RESET',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ])));
  }
}
