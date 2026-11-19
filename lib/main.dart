import 'package:flutter/material.dart';

import 'views/home_view.dart';

void main() {
  runApp(const TeknoNewsApp());
}

class TeknoNewsApp extends StatelessWidget {
  const TeknoNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeknoNews ID',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
