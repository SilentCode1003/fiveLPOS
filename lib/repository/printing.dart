import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class LocalPrint {
  Future<void> printnetwork(NetworkPrinter printer, String ipaddress) async {
    // printer.text('Bold text', styles: const PosStyles(bold: true));
    // printer.text('Reverse text', styles: const PosStyles(reverse: true));
    // printer.text('Underlined text',
    //     styles: const PosStyles(underline: true), linesAfter: 1);
    // printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
    // printer.text('Align center',
    //     styles: const PosStyles(align: PosAlign.center));
    // printer.text('Align right',
    //     styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.text('TEST PRINT', styles: const PosStyles(bold: true));
    printer.text('Company: 5L Solutions Supplys & Allied Services',
        styles: const PosStyles(bold: true));
    printer.text('Developer: Joseph A. Orencio',
        styles: const PosStyles(bold: true));

    printer.feed(2);
    printer.cut();

    // const PaperSize paper = PaperSize.mm80;
    // final profile = await CapabilityProfile.load();

    // print(profile.name);

    // final printer = NetworkPrinter(paper, profile);

    // final PosPrintResult res = await printer.connect('${ipaddress}',
    //     port: 9100, timeout: const Duration(seconds: 1));

    // if (res == PosPrintResult.success) {
    //   print(res.msg);
    //   // print('Print result: ${res.msg}');
    //   // printer.text('TEST');
    //   // printer.feed(5);
    //   // printer.cut();

    // } else {
    //   print('Print result: ${res.msg}');
    // }
  }

  Future<void> testReceipt(NetworkPrinter printer) async {
    printer.text('Bold text', styles: const PosStyles(bold: true));
    printer.text('Reverse text', styles: const PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
    printer.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.feed(2);
    printer.cut();
  }
}
