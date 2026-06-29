import 'package:flutter/material.dart';
import 'screens/home_page.dart'; // 恢復成直接導入主頁面

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quit Smoking Club',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(), // 這裡改回原來的 HomePage()
    );
  }
}
