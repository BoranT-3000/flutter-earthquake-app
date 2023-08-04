import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade500,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 30)),
      ),
    );
  }
}
