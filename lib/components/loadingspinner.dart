import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  String message;
  LoadingSpinner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16.0),
          Text(message),
        ],
      ),
    );
  }
}
