import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'firebase_options.dart';
import 'firebase_config.dart';

import 'screens/app_gate.dart';
import 'usecases/storage/storage_facade_usecase.dart';
import 'usecases/user/user_facade_usecase.dart';
import 'services/user_service.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fnzywzxrwmpfcdcuwznw.supabase.co',
    publishableKey: 'sb_publishable_9oinTfAqSlIUIpaVnGA4xg_O_BDm7Py',
  );

  if (firebaseEnabled) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        final userService = UserService();

        await userService.signInAnonymously();

        currentUser = FirebaseAuth.instance.currentUser;
      }

      if (currentUser != null) {
        UserFacadeUseCase.currentUid = currentUser.uid;

        final userFacade = UserFacadeUseCase();

        final profile = await userFacade.loadProfile(currentUser.uid);

        if (profile != null) {
          await userFacade.syncCloudToLocal(currentUser.uid);
        } else {
          final localName = await StorageFacadeUseCase.getUserName();

          if (localName.isEmpty) {
            await StorageFacadeUseCase.saveUserName('戒菸夥伴');
            await StorageFacadeUseCase.saveDailyCount(5);
            await StorageFacadeUseCase.saveCoins(20);
            await StorageFacadeUseCase.savePremium(false);
          }

          await userFacade.syncLocalToCloud(currentUser.uid);
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Firebase initialize failed: $error');
      debugPrint('$stackTrace');

      await _initLocalUser();
    }
  } else {
    await _initLocalUser();
  }

  runApp(const MyApp());
}

Future<void> _initLocalUser() async {
  final storedName = await StorageFacadeUseCase.getUserName();

  if (storedName.isEmpty) {
    await StorageFacadeUseCase.saveUserName('戒菸夥伴');
    await StorageFacadeUseCase.saveDailyCount(5);
    await StorageFacadeUseCase.saveCoins(20);
    await StorageFacadeUseCase.savePremium(false);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations.of(context)?.appTitle ?? 'Quit Smoking Club',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          primary: const Color(0xFF818CF8),
          secondary: const Color(0xFF34D399),
          surface: const Color(0xFF0F172A),
          surfaceContainer: const Color(0xFF1E293B),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 4,
          shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

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

      home: const GlobalBackground(child: AppGate()),
    );
  }
}

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
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
        ),
      ),
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(scaffoldBackgroundColor: Colors.transparent),
        child: child,
      ),
    );
  }
}
