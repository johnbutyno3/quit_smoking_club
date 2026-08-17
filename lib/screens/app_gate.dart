import 'package:flutter/material.dart';

import 'login_page.dart';
import 'intro_page.dart';
import 'onboarding_setup_page.dart';
import 'main_navigation_page.dart';

import '../usecases/storage/storage_facade_usecase.dart';
import '../usecases/user/user_facade_usecase.dart';

/// Development switch: keep login bypassed until the V3 product is complete.
/// Set to true before production release to restore the normal login flow.
const bool kRequireLogin = false;

/// V3 development switch: skip the legacy intro screen so the current
/// navigation shell can be verified directly.
const bool kSkipIntroForV3 = true;

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
      if (kSkipIntroForV3) {
        if (!mounted) return;
        setState(() {
          _page = const MainNavigationPage();
          _loading = false;
        });
        return;
      }

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

      if (!kRequireLogin) {
        if (!mounted) return;
        setState(() {
          _page = const MainNavigationPage();
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
        _page = const MainNavigationPage();
        _loading = false;
      });
    } catch (error) {
      debugPrint('[AppGate] initialization error: $error');
      if (!mounted) return;
      setState(() {
        _page = kRequireLogin
            ? const LoginPage()
            : const MainNavigationPage();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _page ?? const LoginPage();
  }
}
