import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._constructor();

  DatabaseHelper._constructor();
  Future<Database> get database async {
    return _database ?? await _initDatabase();

    // if (_database != null) return _database;
    // _database = await _initDatabase();
    // return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'posconfig.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''CREATE TABLE category 
        (categorycode INT PRIMARY KEY, 
        categoryname VARCHAR(300), 
        status VARCHAR(20), 
        createdby VARCHAR(300), 
        createddate VARCHAR(20))''');
    print('done creating category table');

    await db.execute('''CREATE TABLE productprice 
        (productid INT PRIMARY KEY, 
        description VARCHAR(300) NOT NULL,
        barcode VARCHAR(20) NOT NULL, 
        price DECIMAL(10,2) NOT NULL,
        category INT NOT NULL,
        quantity INT NOT NULL)''');
    print('done creating productprice table');

    await db.execute('''CREATE TABLE discount 
        (discountid INT PRIMARY KEY, 
        discountname VARCHAR(300) NOT NULL, 
        description VARCHAR(300) NOT NULL, 
        rate DECIMAL(5,2) NOT NULL,
        status VARCHAR(20) NOT NULL,
        createdby VARCHAR(300) NOT NULL,
        createddate VARCHAR(20) NOT NULL)''');
    print('done creating discount table');

    await db.execute('''CREATE TABLE promo 
        (promoid INT PRIMARY KEY, 
        name VARCHAR(300) NOT NULL, 
        description VARCHAR(300) NOT NULL, 
        dtipermit VARCHAR(20) NOT NULL,
        condition TEXT NOT NULL,
        startdate VARCHAR(20) NOT NULL,
        enddate VARCHAR(20) NOT NULL,
        status VARCHAR(20) NOT NULL,
        createdby VARCHAR(300) NOT NULL,
        createddate VARCHAR(20) NOT NULL)''');
    print('done creating promo table');

    await db.execute('''CREATE TABLE payments 
        (id INT AUTO_INCREMENT PRIMARY KEY, 
        paymentname VARCHAR(300) NOT NULL)''');
    print('done creating payments table');

    await db.execute('''CREATE TABLE employees
        (id INT AUTO_INCREMENT  PRIMARY KEY, 
        fullname VARCHAR(300) NOT NULL)''');
    print('done creating employees table');

    await db.execute('''CREATE TABLE posdetailid
        (id INT AUTO_INCREMENT  PRIMARY KEY, 
        detailid int NOT NULL)''');
    print('done creating posdetailid table');

    await db.execute('''CREATE TABLE posshift
        (posid INT  PRIMARY KEY, 
        date varchar(20) NOT NULL,
        shift int NOT NULL,
        status varchar(20) NOT NULL)''');
    print('done creating posshift table');
  }

  Future<int> insertItem(Map<String, dynamic> item, String tablename) async {
    Database db = await database;
    return await db.insert(tablename, item);
  }

  Future<void> updateItem(Map<String, dynamic> data, String tablename,
      String condition, dynamic agrs) async {
    Database db = await database;

    await db.update(tablename, data, where: condition, whereArgs: [agrs]);
  }

  Future<List<Map<String, dynamic>>> selectItem(table) async {
    Database db = await database;
    final data = await db.query(table);
    print(data);

    return data;
  }

  Future<void> deleteItem(table) async {
    Database db = await database;

    await db.delete(table);
  }
}
