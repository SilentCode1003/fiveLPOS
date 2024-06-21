import 'dart:convert';

import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Helper {
  String GetCurrentDatetime() {
    DateTime currentDateTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm').format(currentDateTime);
    return formattedDateTime;
  }

  String GetCurrentDate() {
    DateTime currentDateTime = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd').format(currentDateTime);
    return formattedDateTime;
  }

  //Windows
  Future<Map<String, dynamic>> readJsonToFile(String filePath) async {
    final directory = Directory.current.path;
    final file = File('$directory/$filePath');

    print('JSON data read to: $file');

    // Check if the file exists
    if (!file.existsSync()) {
      print('File does not exist.');
    }

    // Read the contents of the file
    String jsonString = await file.readAsString();

    // Parse the JSON string into a Map
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    return jsonData;
  }

  Future<dynamic> readJsonListToFile(String filePath) async {
    final directory = Directory.current.path;
    final file = File('$directory/$filePath');

    print('JSON data read to: $file');

    // Check if the file exists
    if (!file.existsSync()) {
      print('File does not exist.');
    }

    // Read the contents of the file
    String jsonString = await file.readAsString();

    // Parse the JSON string into a Map
    dynamic jsonData = jsonDecode(jsonString);

    return jsonData;
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

  String formatAsCurrency(double value) {
    return toCurrencyString(value.toString());
  }

  Future<void> deleteFile(String filepath) async {
    try {
      File file = File(filepath);

      if (await file.exists()) {
        await file.delete();
      } else {
        print('File not found');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> writeJsonToFile(
      Map<String, dynamic> jsnonData, String filePath) async {
    try {
      final directory = Directory.current.path;
      final file = File('$directory/$filePath');

      // Convert the data to a JSON string
      String jsonString = jsonEncode(jsnonData);

      // Write the JSON string to the file
      await file.writeAsString(jsonString);

      print('Data written to ${file.path} data: $jsnonData');
    } catch (e) {
      print(e);
    }
  }

  Future<void> writeListJsonToFile(
      List<Map<String, dynamic>> jsnonData, String filePath) async {
    try {
      final directory = Directory.current.path;
      final file = File('$directory/$filePath');

      // Convert the data to a JSON string
      String jsonString = jsonEncode(jsnonData);

      // Write the JSON string to the file
      await file.writeAsString(jsonString);

      print('Data written to ${file.path} data: $jsnonData');
    } catch (e) {
      print(e);
    }
  }

  //Android
  Future<void> jsonToFileWriteAndroid(
      Map<String, dynamic> jsonData, String filename) async {
    try {
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // Write JSON data to file
      final file = File(filePath);

      await file.writeAsString(json.encode(jsonData));

      print('JSON data written to: $filePath');
    } catch (e) {
      print('Error writing JSON data: $e');
    }
  }

  Future<Map<String, dynamic>> jsonToFileReadAndroid(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    print('JSON data read to: $filePath');

    // Check if the file exists
    if (!file.existsSync()) {
      print('File does not exist.');
    }

    // Read the contents of the file
    String jsonString = await file.readAsString();

    // Parse the JSON string into a Map
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    return jsonData;
  }

  Future<void> jsonListToFileWriteAndroid(
      List<Map<String, dynamic>> jsonData, String filename) async {
    try {
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';

      // Write JSON data to file
      final file = File(filePath);

      await file.writeAsString(json.encode(jsonData));

      print('JSON data written to: $filePath');
    } catch (e) {
      print('Error writing JSON data: $e');
    }
  }

  Future<dynamic> jsonListToFileReadAndroid(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    print('JSON data read to: $filePath');

    // Check if the file exists
    if (!file.existsSync()) {
      print('File does not exist.');
    }

    // Read the contents of the file
    String jsonString = await file.readAsString();


    // Parse the JSON string into a Map
    dynamic jsonData = jsonDecode(jsonString);

    return jsonData;
  }

// Function to read existing data from the JSON file
Future<List<dynamic>> readJsonFile(String filePath) async {
  try {
    final file = File(filePath);
    if (await file.exists()) {
      final contents = await file.readAsString();
      return jsonDecode(contents);
    }
  } catch (e) {
    print('Error reading JSON file: $e');
  }
  // Return an empty list if the file doesn't exist or an error occurs
  return [];
}

// Function to append new data to the existing list
Future<void> appendDataToJsonFile(String filePath, Map<String, dynamic> newData) async {
  // Read existing data
  List<dynamic> data = await readJsonFile(filePath);

  // Append the new data
  data.add(newData);

  // Write the updated data back to the JSON file
  final file = File(filePath);
  await file.writeAsString(jsonEncode(data), flush: true);
}

}
