import 'package:flutter/material.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'intro_page.dart';
import 'onboarding_setup_page.dart';

import '../usecases/storage/storage_facade_usecase.dart';
import '../usecases/user/user_facade_usecase.dart';

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
      // Check whether introduction has been shown
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

      // Check current user
      final uid = UserFacadeUseCase.currentUid;

      if (uid == null || uid.isEmpty) {
        if (!mounted) return;

        setState(() {
          _page = const LoginPage();
          _loading = false;
        });

        return;
      }

      // Load user profile
      final userFacade = UserFacadeUseCase();

      final profile = await userFacade.loadProfile(uid);

      // User logged in but profile not completed
      if (profile == null) {
        if (!mounted) return;

        setState(() {
          _page = OnboardingSetupPage(uid: uid, userFacade: userFacade);

          _loading = false;
        });

        return;
      }

      // User ready
      if (!mounted) return;

      setState(() {
        _page = const HomePage();
        _loading = false;
      });
    } catch (error) {
      debugPrint('[AppGate] initialization error: $error');

      if (!mounted) return;

      setState(() {
        _page = const LoginPage();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _page ?? const LoginPage();
  }
}
