import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/onboarding_page.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 測試大絕招：強制清除硬碟名稱快取
  await StorageService.saveUserName("");

  final storedName = await StorageService.getUserName();
  final isFirstTime = storedName.isEmpty;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quit Smoking Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: isFirstTime ? const OnboardingPage() : const HomePage(),
    );
  }
}
