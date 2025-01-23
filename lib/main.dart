import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:sirisoft_test/screen.dart';

void main() {
  runApp(GetMaterialApp(
    home: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitcoin tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
