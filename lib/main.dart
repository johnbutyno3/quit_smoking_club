import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/onboarding_page.dart';
import 'services/content_service_firebase.dart';
import 'services/storage_service.dart';
import 'supabase_config.dart';
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseEnabled) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  if (firebaseEnabled) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await ContentServiceFirebase().seedSampleContent();
  }

  final storedName = await StorageService.getUserName();
  final isFirstTime = storedName.isEmpty;
  if (isFirstTime) {
    await StorageService.saveDailyCount(5);
  }

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
