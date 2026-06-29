import 'package:flutter/material.dart';
import 'screens/home_page.dart';

class QuitSmokingApp extends StatelessWidget {
  const QuitSmokingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '戒菸俱樂部',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const HomePage(),
    );
  }
}
