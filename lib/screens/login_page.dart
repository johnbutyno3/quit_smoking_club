import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../usecases/storage/storage_facade_usecase.dart';
import '../usecases/user/user_facade_usecase.dart';
import 'home_page.dart';
import 'onboarding_setup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LC {
  static const primary = Color(0xFF1B5E20);

  static const bg = Color(0xFFE8F5E9);
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  bool _regPassVisible = false;
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginPassVisible = false;
  bool _isLoading = false;
  String? _error;

  String _localizeNicknameError(String key, AppLocalizations l10n) {
    switch (key) {
      case 'nickname_empty':
        return l10n.nickname_empty;
      case 'nickname_too_short':
        return l10n.nickname_too_short;
      case 'nickname_too_long':
        return l10n.nickname_too_long;
      case 'nickname_invalid_characters':
        return l10n.nickname_invalid_characters;
      case 'nickname_only_numbers':
        return l10n.nickname_only_numbers;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text;
    final nameErr = UserFacadeUseCase.validateNameFormat(name);
    if (nameErr != null) {
      setState(() => _error = _localizeNicknameError(nameErr, l10n));
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.enterValidEmail);
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = l10n.passwordMinLengthError);
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final facade = UserFacadeUseCase();
      final available = await facade.isNameAvailable(name);
      if (!available) {
        setState(() {
          _isLoading = false;
          _error = l10n.usernameAlreadyUsed(name);
        });
        return;
      }
      final uid = await facade.registerWithEmail(email, pass);
      await facade.reserveName(uid, name);
      await StorageFacadeUseCase.saveUserName(name);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingSetupPage(
              uid: uid,
              userFacade: facade,
              prefillName: name,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      String msg = e.toString();
      if (msg.contains('email-already-in-use')) {
        msg = l10n.emailAlreadyRegistered;
      } else if (msg.contains('weak-password')) {
        msg = l10n.weakPassword;
      } else if (msg.contains('invalid-email')) {
        msg = l10n.invalidEmailFormat;
      } else {
        msg = l10n.registrationFailed;
      }
      setState(() => _error = msg);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = l10n.fillEmailAndPassword);
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final facade = UserFacadeUseCase();
      final uid = await facade.signInWithEmail(email, pass);
      final profile = await facade.loadProfile(uid);
      if (profile != null) {
        await facade.syncCloudToLocal(uid);
        _goHome();
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardingSetupPage(
                uid: uid,
                userFacade: facade,
                prefillName: '',
              ),
            ),
          );
        }
      }
    } on Exception catch (e) {
      String msg = e.toString();
      if (msg.contains('user-not-found') ||
          msg.contains('wrong-password') ||
          msg.contains('invalid-credential')) {
        msg = l10n.invalidEmailOrPassword;
      } else if (msg.contains('too-many-requests')) {
        msg = l10n.tooManyAttempts;
      } else {
        msg = l10n.loginFailed;
      }
      setState(() => _error = msg);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final facade = UserFacadeUseCase();
      final uid = await facade.signInWithGoogle();
      final profile = await facade.loadProfile(uid);
      if (profile != null) {
        await facade.syncCloudToLocal(uid);
        _goHome();
      } else {
        _goOnboarding(facade, uid, prefill: facade.googleDisplayName ?? '');
      }
    } catch (e) {
      debugPrint('[LoginPage] Google signIn error: $e');

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = e.toString().contains('取消')
            ? null
            : l10n.loginFailedWithError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goOnboarding(
    UserFacadeUseCase service,
    String uid, {
    String prefill = '',
  }) {
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingSetupPage(
          uid: uid,
          userFacade: service,
          prefillName: prefill,
        ),
      ),
    );
  }

  void _goHome() {
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool? showPass,
    VoidCallback? togglePass,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure && !(showPass ?? false),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (showPass ?? false)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: togglePass,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      onChanged: (_) {
        if (_error != null) {
          setState(() => _error = null);
        }
      },
    );
  }

  Widget _buildLoginFields() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildField(
          ctrl: _loginEmailCtrl,
          label: l10n.loginEmail,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildField(
          ctrl: _loginPassCtrl,
          label: l10n.loginPassword,
          icon: Icons.lock_outlined,
          obscure: true,
          showPass: _loginPassVisible,
          togglePass: () =>
              setState(() => _loginPassVisible = !_loginPassVisible),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        _isLoading
            ? CircularProgressIndicator(color: _LC.primary)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _LC.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleLogin,
                child: Text(
                  l10n.loginWithEmail,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.login, size: 20),
          label: Text(
            l10n.loginWithGoogle,
            style: const TextStyle(fontSize: 15),
          ),
          onPressed: _handleGoogleSignIn,
        ),
      ],
    );
  }

  Widget _buildRegisterFields() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildField(
          ctrl: _regNameCtrl,
          label: l10n.postName,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildField(
          ctrl: _regEmailCtrl,
          label: l10n.loginEmail,
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildField(
          ctrl: _regPassCtrl,
          label: l10n.loginPasswordMinLength,
          icon: Icons.lock_outlined,
          obscure: true,
          showPass: _regPassVisible,
          togglePass: () => setState(() => _regPassVisible = !_regPassVisible),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: _LC.primary)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _LC.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleRegister,
                child: Text(
                  l10n.registerNewAccount,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _LC.bg,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.smoke_free, size: 56, color: _LC.primary),
                const SizedBox(height: 12),
                Text(
                  l10n.loginAppSloganTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _LC.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.loginAppSloganSubtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 28),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      color: _LC.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(text: l10n.loginTabSignIn),
                      Tab(text: l10n.loginTabRegister),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _tabCtrl,
                  builder: (context, _) {
                    return _tabCtrl.index == 0
                        ? _buildLoginFields()
                        : _buildRegisterFields();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
