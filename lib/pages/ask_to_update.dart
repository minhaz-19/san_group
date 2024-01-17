import 'package:flutter/material.dart';

class ask_to_update extends StatefulWidget {
  const ask_to_update({super.key});

  @override
  State<ask_to_update> createState() => _ask_to_updateState();
}

class _ask_to_updateState extends State<ask_to_update> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Please update your app',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
