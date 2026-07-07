import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/intro_page.dart';
import 'services/content_service_firebase.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseOk = false;
  bool alreadySignedIn = false;
  bool introShown = await StorageService.getIntroShown();

  if (firebaseEnabled) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await ContentServiceFirebase().seedSampleContent();
      firebaseOk = true;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        UserService.currentUid = currentUser.uid;
        final service = UserService();
        final profile = await service.loadProfile(currentUser.uid);
        if (profile != null) {
          await service.syncCloudToLocal(currentUser.uid);
        } else {
          final localName = await StorageService.getUserName();
          if (localName.isEmpty) {
            await StorageService.saveUserName('�B��');
            await StorageService.saveDailyCount(5);
            await StorageService.saveCoins(20);
            await StorageService.savePremium(false);
          }
          await service.syncLocalToCloud(currentUser.uid);
        }
        alreadySignedIn = true;
      }
    } catch (error, stackTrace) {
      debugPrint('Firebase initialize failed: $error');
      debugPrint('$stackTrace');
      final storedName = await StorageService.getUserName();
      if (storedName.isEmpty) {
        await StorageService.saveUserName('�B��');
        await StorageService.saveDailyCount(5);
        await StorageService.saveCoins(20);
        await StorageService.savePremium(false);
      }
      alreadySignedIn = true;
    }
  } else {
    final storedName = await StorageService.getUserName();
    if (storedName.isEmpty) {
      await StorageService.saveUserName('�B��');
      await StorageService.saveDailyCount(5);
      await StorageService.saveCoins(20);
      await StorageService.savePremium(false);
    }
    alreadySignedIn = true;
  }

  Widget home;
  if (alreadySignedIn) {
    home = const HomePage();
  } else if (!introShown) {
    await StorageService.saveIntroShown(true);
    home = const IntroPage();
  } else {
    home = const LoginPage();
  }

  runApp(MyApp(home: home));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quit Smoking Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Noto Sans TC',
      ),
      home: home,
    );
  }
}
