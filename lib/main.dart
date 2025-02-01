import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(AgricultureApp());
}

class AgricultureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CropMate',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}
