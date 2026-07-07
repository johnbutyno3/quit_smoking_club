import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'services/content_service_firebase.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';
import 'firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseOk = false;
  bool alreadySignedIn = false;

  if (firebaseEnabled) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await ContentServiceFirebase().seedSampleContent();
      firebaseOk = true;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // 已有登入狀態（Firebase Auth 會自動保持）
        UserService.currentUid = currentUser.uid;
        final service = UserService();
        final profile = await service.loadProfile(currentUser.uid);
        if (profile != null) {
          await service.syncCloudToLocal(currentUser.uid);
        } else {
          // 有 Auth 但無 Firestore 資料 → 同步本機到雲端
          final localName = await StorageService.getUserName();
          if (localName.isEmpty) {
            await StorageService.saveUserName('朋友');
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
      // Firebase 失敗 → 本機保底
      final storedName = await StorageService.getUserName();
      if (storedName.isEmpty) {
        await StorageService.saveUserName('朋友');
        await StorageService.saveDailyCount(5);
        await StorageService.saveCoins(20);
        await StorageService.savePremium(false);
      }
      alreadySignedIn = true; // 降級直接進主頁
    }
  } else {
    // Firebase 未啟用 → 本機保底
    final storedName = await StorageService.getUserName();
    if (storedName.isEmpty) {
      await StorageService.saveUserName('朋友');
      await StorageService.saveDailyCount(5);
      await StorageService.saveCoins(20);
      await StorageService.savePremium(false);
    }
    alreadySignedIn = true;
  }

  runApp(MyApp(showLogin: firebaseOk && !alreadySignedIn));
}

class MyApp extends StatelessWidget {
  final bool showLogin;
  const MyApp({super.key, required this.showLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quit Smoking Club',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: showLogin ? const LoginPage() : const HomePage(),
    );
  }
}
