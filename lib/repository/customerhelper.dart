import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fivelPOS/api/category.dart';
import 'package:fivelPOS/api/checkhealth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    //print('JSON data read to: $file');

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

    //print('JSON data read to: $file');

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

      //print('Data written to ${file.path}');
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

      //print('Data written to ${file.path}');
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

    //print('JSON data read to: $filePath');

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

      //print('JSON data written to: $filePath');
    } catch (e) {
      print('Error writing JSON data: $e');
    }
  }

  Future<dynamic> jsonListToFileReadAndroid(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    //print('JSON data read to: $filePath');

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
        // print('readJsonFile Contents of JSON file: $contents');
        return jsonDecode(contents);
      }
    } catch (e) {
      print('Error reading JSON file: $e');
    }
    // Return an empty list if the file doesn't exist or an error occurs
    return [];
  }

// Function to append new data to the existing list
  Future<void> appendDataToJsonFile(
      String filenname, Map<String, dynamic> newData) async {
    // Read existing data
    List<dynamic> data = [];
    File? file;

    if (Platform.isWindows) {
      //print('Reading JSON file at $filenname');
      data = await readJsonFile(filenname);
      // print('Contents of JSON file: $data');
      file = File(filenname);
    }
    if (Platform.isAndroid) {
      final directory = await getApplicationDocumentsDirectory();
      final fileLocation = '${directory.path}/$filenname';
      //print('Reading JSON file at $fileLocation');

      data = await readJsonFile(fileLocation);
      // print('Contents of JSON file: $data');
      file = File(fileLocation);
    }

    // Append the new data
    //print('New Data: $newData');
    data.add(newData);

    // Write the updated data back to the JSON file

    await file!.writeAsString(jsonEncode(data), flush: true);
  }

  Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No connection at all
      if (Platform.isWindows) {
        print('offline');
        await Helper()
            .writeJsonToFile({'status': 'offline'}, 'networkstatus.json');
      }

      if (Platform.isAndroid) {
        print('offline');
        await Helper().jsonToFileWriteAndroid(
            {'status': 'offline'}, 'networkstatus.json');
      }

      return false;
    } else {
      // Connected to a network, check if we can reach an external server
      print('Local network detected');

      if (Platform.isWindows) {
        print('offline');
        await Helper()
            .writeJsonToFile({'status': 'offline'}, 'networkstatus.json');
      }

      if (Platform.isAndroid) {
        print('offline');
        await Helper().jsonToFileWriteAndroid(
            {'status': 'offline'}, 'networkstatus.json');
      }

      try {
        // int checkConnection = 0;
        // print('Checking internet connection...');

        // await checkAddressWithPort('104.21.85.83', 80).then((value) {
        //   print(value);
        //   if (value) {
        //     checkConnection++;
        //   }
        // });

        // print('checkConnection: $checkConnection');

        print('Internet connection available');

        if (Platform.isWindows) {
          print('online');
          Helper().writeJsonToFile({'status': 'online'}, 'networkstatus.json');
        }

        if (Platform.isAndroid) {
          print('online');
          Helper().jsonToFileWriteAndroid(
              {'status': 'online'}, 'networkstatus.json');
        }
        return true;

        // bool isAlive = await checkHealth();
        // print(isAlive);
        // if (isAlive) {
        //   print('Internet connection available');

        //   if (Platform.isWindows) {
        //     print('online');
        //     Helper()
        //         .writeJsonToFile({'status': 'online'}, 'networkstatus.json');
        //   }

        //   if (Platform.isAndroid) {
        //     print('online');
        //     Helper().jsonToFileWriteAndroid(
        //         {'status': 'online'}, 'networkstatus.json');
        //   }
        //   return true;
        // } else {
        //   print('Internet connection not available');
        //   if (Platform.isWindows) {
        //     print('offline');
        //     Helper()
        //         .writeJsonToFile({'status': 'offline'}, 'networkstatus.json');
        //   }

        //   if (Platform.isAndroid) {
        //     print('offline');
        //     Helper().jsonToFileWriteAndroid(
        //         {'status': 'offline'}, 'networkstatus.json');
        //   }
        //   return false;
        // }
      } catch (error) {
        print('Error: $error \n Internet connection not available');
        return false;
      }
    }
  }

  Future<bool> checkAddressWithPort(String address, int port) async {
    try {
      final socket = await Socket.connect(address, port,
          timeout: const Duration(seconds: 5));

      print(socket.remoteAddress.address);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await CheckHealthAPI().getCheckHealth();
      if (response['status'] == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> resetJsonFileArrayAndroid(filename) async {
    try {
      // Get the current working

      final directory = await getApplicationDocumentsDirectory();

      // Specify the file name and path
      final filePath = '${directory.path}/$filename';

      // Create a File object
      final File file = File(filePath);

      // Convert the Map to a JSON string
      String jsonString = '[]';

      // Write the JSON string to the file
      file.writeAsStringSync(jsonString);

      print('JSON file created successfully at: $filePath');
    } catch (e) {
      print('Error creating JSON file: $e');
    }
  }

  Future<void> resetJsonFileArray(filename) async {
    try {
      // Get the current working

      final currentDirectory = Platform.isAndroid
          ? getApplicationDocumentsDirectory()
          : Directory.current.path;

      // Specify the file name and path
      final String filePath = '$currentDirectory/$filename';

      // Create a File object
      final File file = File(filePath);

      // Convert the Map to a JSON string
      String jsonString = '[]';

      // Write the JSON string to the file
      file.writeAsStringSync(jsonString);

      print('JSON file created successfully at: $filePath');
    } catch (e) {
      print('Error creating JSON file: $e');
    }
  }

  Future<void> writeAssetData(
      String filename, String type, String content) async {
    try {
      final currentDirectory = Platform.isAndroid
          ? getApplicationDocumentsDirectory()
          : Directory.current.path;

      final String filePath = '$currentDirectory/$filename.$type';

      print(filePath);

      final File file = File(filePath);

      await file.writeAsString(content);
      print('File created successfully at: $filePath');
    } catch (e) {
      print('Error writing SVG to file: $e');
    }
  }

  Future<Uint8List> svgToPng(String svgString) async {
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    final image = await pictureInfo.picture.toImage(250, 250);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Unable to convert SVG to PNG');
    }

    final pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }
}
