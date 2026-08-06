import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/intro_page.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';
import 'firebase_config.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fnzywzxrwmpfcdcuwznw.supabase.co',
    publishableKey: 'sb_publishable_9oinTfAqSlIUIpaVnGA4xg_O_BDm7Py',
  );

  bool firebaseOk = false;
  bool alreadySignedIn = false;
  bool introShown = await StorageService.getIntroShown();

  // ignore_for_file: unused_local_variable, unused_import
  if (firebaseEnabled) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseOk = true;

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        final credential = await FirebaseAuth.instance.signInAnonymously();

        currentUser = credential.user;
      }
      if (currentUser != null) {
        UserService.currentUid = currentUser.uid;
        final service = UserService();
        final profile = await service.loadProfile(currentUser.uid);
        if (profile != null) {
          await service.syncCloudToLocal(currentUser.uid);
        } else {
          final localName = await StorageService.getUserName();
          if (localName.isEmpty) {
            await StorageService.saveUserName('戒菸夥伴');
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
        await StorageService.saveUserName('戒菸夥伴');
        await StorageService.saveDailyCount(5);
        await StorageService.saveCoins(20);
        await StorageService.savePremium(false);
      }
      alreadySignedIn = true;
    }
  } else {
    final storedName = await StorageService.getUserName();
    if (storedName.isEmpty) {
      await StorageService.saveUserName('戒菸夥伴');
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

// ========================================================
// 完美支援新版 Flutter 語法的高質感主題設定
// ========================================================
class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quit Smoking Club',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      supportedLocales: AppLocalizations.supportedLocales,

      // 🎨 全局暗色系與質感風格設定
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // ✨ 新版規範：移除了已淘汰的 background，全面整合至 colorScheme 中
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          primary: const Color(0xFF818CF8), // 主色調
          secondary: const Color(0xFF34D399), // 戒菸成功的亮點點綴色
          surface: const Color(0xFF0F172A), // 基礎背景色
          surfaceContainer: const Color(0xFF1E293B), // 新版標準的卡片基底色
        ),

        // ✨ 新版規範：將 CardTheme 修正為 CardThemeData，避免型態報錯
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 4,
          // ✨ 新版規範：修正 withOpacity 報錯，全面改用新版 withValues 處理透明度
          shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // 📝 統一輸入框（TextField）設計
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
          ),
        ),
      ),

      // 💡 透過自訂背景底座，讓所有子頁面自動透出精美漸層
      home: GlobalBackground(child: home),
    );
  }
}

// ========================================================
// 🧱 全局高質感深邃漸層背景底座
// ========================================================
class GlobalBackground extends StatelessWidget {
  final Widget child;
  const GlobalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1B4B), // 頂部：暗深藍紫
            Color(0xFF0F172A), // 底部：深邃星空黑
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: Colors.transparent, // 關鍵：讓所有頁面底色透明，透出上方的漸層
        ),
        child: child,
      ),
    );
  }
}
