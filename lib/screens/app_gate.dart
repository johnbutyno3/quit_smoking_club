import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'intro_page.dart';
import 'onboarding_setup_page.dart';

import '../usecases/storage/storage_facade_usecase.dart';
import '../usecases/user/user_facade_usecase.dart';

// Temporary development setting.
// Set to true while completing and testing V3 without login.
// Restore to false before production release.
const bool kRequireLogin = false;

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _loading = true;
  Widget? _page;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      final introShown = await StorageFacadeUseCase.getIntroShown();

      if (!introShown) {
        await StorageFacadeUseCase.saveIntroShown(true);

        if (!mounted) return;

        setState(() {
          _page = const IntroPage();
          _loading = false;
        });

        return;
      }

      // Development mode: bypass login and onboarding so V3 features
      // can be tested directly from the HomePage.
      if (!kRequireLogin) {
        if (!mounted) return;

        setState(() {
          _page = const HomePage();
          _loading = false;
        });

        return;
      }

      final uid = UserFacadeUseCase.currentUid;

      if (uid == null || uid.isEmpty) {
        if (!mounted) return;

        setState(() {
          _page = const LoginPage();
          _loading = false;
        });

        return;
      }

      final userFacade = UserFacadeUseCase();
      final profile = await userFacade.loadProfile(uid);

      if (profile == null) {
        if (!mounted) return;

        setState(() {
          _page = OnboardingSetupPage(uid: uid, userFacade: userFacade);
          _loading = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        _page = const HomePage();
        _loading = false;
      });
    } catch (error) {
      debugPrint('[AppGate] initialization error: $error');

      if (!mounted) return;

      setState(() {
        _page = kRequireLogin ? const LoginPage() : const HomePage();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _page ?? (kRequireLogin ? const LoginPage() : const HomePage());
  }
}
