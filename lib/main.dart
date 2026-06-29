import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/onboarding_page.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 💡 安全防禦：如果硬碟因為先前測試卡住，強制寫入基本安全數字
  final storedName = await StorageService.getUserName();
  if (storedName == "User" || storedName.isEmpty) {
    await StorageService.saveDailyCount(5);
    await StorageService.saveUserName("");
  }

  final latestName = await StorageService.getUserName();
  final isFirstTime = latestName.isEmpty;

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
