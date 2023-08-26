import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';

import 'package:pos2/model/branch.dart';

class Helper {
  String GetCurrentDatetime() {
    DateTime currentDateTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm').format(currentDateTime);
    return formattedDateTime;
  }

  Future<String> readJsonFile(String filePath) async {
    String fileContent = await readFileContent(filePath);
    return fileContent;
  }

  Future<String> readFileContent(String filePath) async {
    try {
      File file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      print('Error reading file: $e');
      return '';
    }
  }
}
