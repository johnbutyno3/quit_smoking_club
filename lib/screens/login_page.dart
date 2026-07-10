import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';
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
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text;
    final nameErr = UserService.validateNameFormat(name);
    if (nameErr != null) {
      setState(() => _error = nameErr);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = '請輸入正確的電子郵件');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = '密碼至少需要 6 個字元');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = UserService();
      final available = await service.isNameAvailable(name);
      if (!available) {
        setState(() {
          _isLoading = false;
          _error = '該名稱「$name」已被使用，請換一個暱稱';
        });
        return;
      }
      final uid = await service.registerWithEmail(email, pass);
      await service.reserveName(uid, name);
      await StorageService.saveUserName(name);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingSetupPage(
              uid: uid,
              userService: service,
              prefillName: name,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      String msg = e.toString();
      if (msg.contains('email-already-in-use')) {
        msg = '此電子郵件已被註冊，請直接登入';
      } else if (msg.contains('weak-password')) {
        msg = '密碼強度不足';
      } else if (msg.contains('invalid-email')) {
        msg = '電子郵件格式不正確';
      } else {
        msg = '註冊失敗，請稍後再試';
      }
      setState(() => _error = msg);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = '請填寫電子郵件與密碼');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = UserService();
      final uid = await service.signInWithEmail(email, pass);
      final profile = await service.loadProfile(uid);
      if (profile != null) {
        await service.syncCloudToLocal(uid);
        _goHome();
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OnboardingSetupPage(
                uid: uid,
                userService: service,
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
        msg = '電子郵件或密碼不正確';
      } else if (msg.contains('too-many-requests')) {
        msg = '嘗試次數過多，請稍後再試';
      } else {
        msg = '登入失敗，請稍後再試';
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
      final service = UserService();
      final uid = await service.signInWithGoogle();
      final profile = await service.loadProfile(uid);
      if (profile != null) {
        await service.syncCloudToLocal(uid);
        _goHome();
      } else {
        _goOnboarding(service, uid, prefill: service.googleDisplayName ?? '');
      }
    } catch (e) {
      debugPrint('[LoginPage] Google signIn error: $e');
      setState(() {
        _error = e.toString().contains('取消') ? null : '登入失敗：$e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goOnboarding(UserService service, String uid, {String prefill = ''}) {
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingSetupPage(
          uid: uid,
          userService: service,
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
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildField(
          ctrl: _loginEmailCtrl,
          label: '電子郵件',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildField(
          ctrl: _loginPassCtrl,
          label: '密碼',
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
                child: const Text(
                  '信箱登入',
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
          label: const Text('使用 Google 帳號登入', style: TextStyle(fontSize: 15)),
          onPressed: _handleGoogleSignIn,
        ),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildField(
          ctrl: _regNameCtrl,
          label: '暱稱',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildField(
          ctrl: _regEmailCtrl,
          label: '電子郵件',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        _buildField(
          ctrl: _regPassCtrl,
          label: '密碼 (至少6碼)',
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
                child: const Text(
                  '註冊新帳號',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  '戒菸好習慣',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _LC.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '陪你每天一步一步戒菸',
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
                    tabs: const [
                      Tab(text: '登入'),
                      Tab(text: '註冊'),
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
