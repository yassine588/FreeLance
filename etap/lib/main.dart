import 'package:flutter/material.dart';
import 'package:etap/Components/LoginPage.dart';
import 'package:etap/Components/Signup.dart';
import 'package:etap/Components/Home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EtapPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => EtapPage(),
      },
    );
  }
}