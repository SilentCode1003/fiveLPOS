// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CircularProgressBar extends StatelessWidget {
  String status;
  String module;
  CircularProgressBar({
    Key? key,
    required this.status,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 120,
        width: 320,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(status),
          const SizedBox(height: 16.0),
          Text('Please wait while sycing to $module')
        ]),
      ),
    );
  }
}
