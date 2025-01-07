import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class LocalPrint {
  Future<void> printnetwork(String ipaddress) async {
    PrinterNetworkManager printer = PrinterNetworkManager(ipaddress);

    PosPrintResult printing =
        await printer.printTicket(await transactionReceipt());

    print(printing.msg);
  }

  Future<List<int>> transactionReceipt() async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    final Generator printer = Generator(paper, profile);
    List<int> bytes = [];

    bytes += printer.text('TEST PRINT', styles: const PosStyles(bold: true));
    bytes += printer.text('Company: 5L Solutions Supplys & Allied Services',
        styles: const PosStyles(bold: true));
    bytes += printer.text('Developer: Joseph A. Orencio',
        styles: const PosStyles(bold: true));
    bytes += printer.text('Contact: 09364423663',
        styles: const PosStyles(bold: true));
    bytes += printer.text('Web: https://www.5lsolutions.com/',
        styles: const PosStyles(bold: true));

    bytes += printer.feed(2);
    bytes += printer.cut();

    return bytes;
  }
}
