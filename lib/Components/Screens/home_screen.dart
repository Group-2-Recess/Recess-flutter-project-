import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<String> medications;

  HomeScreen({required this.medications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: ListView.builder(
        itemCount: medications.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(medications[index]),
          );
        },
      ),
    );
  }
}
