import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:news_project/home_screen.dart';
import 'package:news_project/inside_screen.dart';

void main() {
  runApp(DevicePreview(
      builder: (context) => MyApp(),
));

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Compact',
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}