import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pos2/repository/dbhelper.dart';
import 'package:sqflite_common/sqlite_api.dart';

class Email {
  final String username = "5lpos@5lsolutions.com";
  final String password = "5lpointofsales";
  DatabaseHelper dbHelper = DatabaseHelper();
  final String css = """
<style>
/* -------------------------------------
    GLOBAL
    A very basic CSS reset
------------------------------------- */
* {
    margin: 0;
    padding: 0;
    font-family: "Helvetica Neue", "Helvetica", Helvetica, Arial, sans-serif;
    box-sizing: border-box;
    font-size: 14px;
}

img {
    max-width: 100%;
}

body {
    -webkit-font-smoothing: antialiased;
    -webkit-text-size-adjust: none;
    width: 100% !important;
    height: 100%;
    line-height: 1.6;
}

/* Let's make sure all tables have defaults */
table td {
    vertical-align: top;
}

/* -------------------------------------
    BODY & CONTAINER
------------------------------------- */
body {
    background-color: #f6f6f6;
}

.body-wrap {
    background-color: #f6f6f6;
    width: 100%;
}

.container {
    display: block !important;
    max-width: 600px !important;
    margin: 0 auto !important;
    /* makes it centered */
    clear: both !important;
}

.content {
    max-width: 600px;
    margin: 0 auto;
    display: block;
    padding: 20px;
}

/* -------------------------------------
    HEADER, FOOTER, MAIN
------------------------------------- */
.main {
    background: #fff;
    border: 1px solid #e9e9e9;
    border-radius: 3px;
}

.content-wrap {
    padding: 20px;
}

.content-block {
    padding: 0 0 20px;
}

.header {
    width: 100%;
    margin-bottom: 20px;
}

.footer {
    width: 100%;
    clear: both;
    color: #999;
    padding: 20px;
}
.footer a {
    color: #999;
}
.footer p, .footer a, .footer unsubscribe, .footer td {
    font-size: 12px;
}

/* -------------------------------------
    TYPOGRAPHY
------------------------------------- */
h1, h2, h3 {
    font-family: "Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif;
    color: #000;
    margin: 40px 0 0;
    line-height: 1.2;
    font-weight: 400;
}

h1 {
    font-size: 32px;
    font-weight: 500;
}

h2 {
    font-size: 24px;
}

h3 {
    font-size: 18px;
}

h4 {
    font-size: 14px;
    font-weight: 600;
}

p, ul, ol {
    margin-bottom: 10px;
    font-weight: normal;
}
p li, ul li, ol li {
    margin-left: 5px;
    list-style-position: inside;
}

/* -------------------------------------
    LINKS & BUTTONS
------------------------------------- */
a {
    color: #1ab394;
    text-decoration: underline;
}

.btn-primary {
    text-decoration: none;
    color: #FFF;
    background-color: #1ab394;
    border: solid #1ab394;
    border-width: 5px 10px;
    line-height: 2;
    font-weight: bold;
    text-align: center;
    cursor: pointer;
    display: inline-block;
    border-radius: 5px;
    text-transform: capitalize;
}

/* -------------------------------------
    OTHER STYLES THAT MIGHT BE USEFUL
------------------------------------- */
.last {
    margin-bottom: 0;
}

.first {
    margin-top: 0;
}

.aligncenter {
    text-align: center;
}

.alignright {
    text-align: right;
}

.alignleft {
    text-align: left;
}

.clear {
    clear: both;
}

/* -------------------------------------
    ALERTS
    Change the class depending on warning email, good email or bad email
------------------------------------- */
.alert {
    font-size: 16px;
    color: #fff;
    font-weight: 500;
    padding: 20px;
    text-align: center;
    border-radius: 3px 3px 0 0;
}
.alert a {
    color: #fff;
    text-decoration: none;
    font-weight: 500;
    font-size: 16px;
}
.alert.alert-warning {
    background: #f8ac59;
}
.alert.alert-bad {
    background: #ed5565;
}
.alert.alert-good {
    background: #1ab394;
}

/* -------------------------------------
    INVOICE
    Styles for the billing table
------------------------------------- */
.invoice {
    margin: 40px auto;
    text-align: left;
    width: 80%;
}
.invoice td {
    padding: 5px 0;
}
.invoice .invoice-items {
    width: 100%;
}
.invoice .invoice-items td {
    border-top: #eee 1px solid;
}
.invoice .invoice-items .total td {
    border-top: 2px solid #333;
    border-bottom: 2px solid #333;
    font-weight: 700;
}

/* -------------------------------------
    RESPONSIVE AND MOBILE FRIENDLY STYLES
------------------------------------- */
@media only screen and (max-width: 640px) {
    h1, h2, h3, h4 {
        font-weight: 600 !important;
        margin: 20px 0 5px !important;
    }

    h1 {
        font-size: 22px !important;
    }

    h2 {
        font-size: 18px !important;
    }

    h3 {
        font-size: 16px !important;
    }

    .container {
        width: 100% !important;
    }

    .content, .content-wrap {
        padding: 10px !important;
    }

    .invoice {
        width: 100% !important;
    }
}
</style>
""";

  Future<String> sendMail(
      String or,
      String recipient,
      Uint8List ereceipt,
      String cashier,
      List<Map<String, dynamic>> itemsList,
      String paymenttype,
      String referenceid) async {
    String id = '';
    String posname = '';
    String serial = '';
    String min = '';
    String ptu = '';

    String branchid = '';
    String branchname = '';
    String tin = '';
    List<String> address = [];
    List<String> logo = [];

    String date = DateTime.now().toString();

    Database db = await dbHelper.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');
    for (var pos in posconfig) {
      id = pos['posid'].toString();
      posname = pos['posname'];
      serial = pos['serial'];
      min = pos['min'];
      ptu = 'PTU: ${pos['ptu']}';
    }

    List<Map<String, dynamic>> branchconfig = await db.query('branch');
    for (var branch in branchconfig) {
      branchid = branch['branchid'].toString();
      branchname = branch['branchname'];
      tin = 'VAT REG TIN: ${branch['tin']}';
      address = branch['address'].toString().split(',').toList();
      logo = utf8.decode(base64.decode(branch['logo'])).split('<svg');
    }

    String location = '';
    for (String addr in address) {
      location += '$addr ';
    }

    double total = 0;
    String items = '';
    for (int index = 0; index < itemsList.length; index++) {
      items += """
          <tr>
            <td>${itemsList[index]['name']}</td>
            <td class="alignright">${itemsList[index]['quantity']}</td>
            <td class="alignright">${itemsList[index]['price']}</td>
            <td class="alignright">${itemsList[index]['price'] * itemsList[index]['quantity']}</td>
          </tr>
""";

      total += itemsList[index]['price'] * itemsList[index]['quantity'];
    }

    String details = '';
    if (paymenttype != 'CASH') {
      details =
          'Cashier: $cashier<br>POS ID:$id<br>OR#: $or<br>Date: $date<br>Payment Type: $paymenttype<br>Ref. #: $referenceid';
    } else {
      details =
          'Cashier: $cashier<br>POS ID:$id<br>OR#: $or<br>Date: $date<br>Payment Type: $paymenttype';
    }

    final directory = await getTemporaryDirectory();

    final pdfFile = File('${directory.path}/$or.pdf');

    await pdfFile.writeAsBytes(ereceipt);

    final smtpServer = SmtpServer('mail.5lsolutions.com',
        username: username, password: password, port: 587, ssl: false);

    final message = Message()
      ..from = Address(username)
      ..recipients.add(recipient)
      ..subject = '$branchname - OR#:$or [E-Receipt]'
      ..text =
          'Good Day,\n\n Thank you for purchase, please see attached receipt.'
      ..html = '''
<html>
<head>
$css
</head>
<body>
<table class="body-wrap">
    <tbody><tr>
        <td></td>
        <td class="container" width="600">
            <div class="content">
                <table class="main" width="100%" cellpadding="0" cellspacing="0">
                    <tbody><tr>
                        <td class="content-wrap aligncenter">
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tbody><tr>
                                    <td class="content-block">
                                        <h2>Thank You</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="content-block">
                                        <table class="invoice">
                                            <tbody><tr>
                                                <td>$details</td>
                                        
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table class="invoice-items" cellpadding="0" cellspacing="10">
                                                        <thead>
                                                          <th>Item</th>
                                                          <th>Qty</th>
                                                          <th>Price</th>
                                                          <th>Subtotal</th>
                                                        </thead>
                                                        <tbody>
                                                          $items
                                                          <tr class="total">
                                                              <td class="alignright" width="80%">Total</td>
                                                              <td></td>
                                                              <td></td>
                                                              <td class="alignright">$total</td>
                                                          </tr>
                                                        </tbody>
                                                    </table>
                                                </td>
                                            </tr>
                                        </tbody></table>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="content-block">
                                     $location
                                    </td>
                                </tr>
                            </tbody></table>
                        </td>
                    </tr>
                </tbody></table>
                <div class="footer">
                    <table width="100%">
                        <tbody><tr>
                            <td class="aligncenter content-block">Questions? Email <a href="mailto:">support@company.inc</a></td>
                        </tr>
                    </tbody></table>
                </div></div>
        </td>
        <td></td>
    </tr>
</tbody></table>
</body>
</html>



              '''
      ..attachments.add(FileAttachment(pdfFile));

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');

      return 'success';
    } on MailerException catch (e) {
      print('Message not sent. Error: ${e.message}');

      return e.message;
    }
  }
}
