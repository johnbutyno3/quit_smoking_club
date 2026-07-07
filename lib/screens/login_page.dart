import 'package:flutter/foundation.dart';
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
  static const accent = Color(0xFF4CAF50);
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
      setState(() => _error = '請輸入有效的電子郵件');
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
          _error = '「$name」已被使用，請換一個暱稱';
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
      if (msg.contains('email-already-in-use'))
        msg = '此電子郵件已被註冊，請直接登入';
      else if (msg.contains('weak-password'))
        msg = '密碼強度不足';
      else if (msg.contains('invalid-email'))
        msg = '電子郵件格式不正確';
      else
        msg = '註冊失敗，請稍後再試';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        if (mounted)
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
      if (mounted) setState(() => _isLoading = false);
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
        final displayName = service.googleDisplayName ?? '';
        _goOnboarding(service, uid, prefill: displayName);
      }
    } catch (e) {
      debugPrint('[LoginPage] Google signIn error: $e');
      setState(() {
        _error = e.toString().contains('取消') ? null : '登入失敗：$e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goOnboarding(UserService service, String uid, {String prefill = ''}) {
    if (!mounted) return;
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
    if (!mounted) return;
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
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure && !(showPass ?? false),
      keyboardType: keyboardType,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LC.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.smoke_free, size: 48, color: _LC.primary),
            const SizedBox(height: 8),
            const Text(
              '戒菸好幫手',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _LC.primary,
              ),
            ),
            const Text(
              '與你同行，一步一步戒菸',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
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
                unselectedLabelColor: Colors.grey,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '建立帳號'),
                  Tab(text: '登入'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [_buildRegisterTab(), _buildLoginTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          _buildField(
            ctrl: _regNameCtrl,
            label: '暱稱',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildField(
            ctrl: _regEmailCtrl,
            label: '電子郵件',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildField(
            ctrl: _regPassCtrl,
            label: '密碼（至少 6 碼）',
            icon: Icons.lock_outline,
            obscure: true,
            showPass: _regPassVisible,
            togglePass: () =>
                setState(() => _regPassVisible = !_regPassVisible),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          _buildPrimaryButton('建立帳號 →', _isLoading ? null : _handleRegister),
          const SizedBox(height: 12),
          if (kIsWeb) _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          _buildField(
            ctrl: _loginEmailCtrl,
            label: '電子郵件',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildField(
            ctrl: _loginPassCtrl,
            label: '密碼',
            icon: Icons.lock_outline,
            obscure: true,
            showPass: _loginPassVisible,
            togglePass: () =>
                setState(() => _loginPassVisible = !_loginPassVisible),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          _buildPrimaryButton('登入', _isLoading ? null : _handleLogin),
          const SizedBox(height: 12),
          if (kIsWeb) _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _LC.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Image.network(
        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 20),
      ),
      label: const Text(
        '以 Google 帳號繼續',
        style: TextStyle(color: Colors.black87),
      ),
      onPressed: _isLoading ? null : _handleGoogleSignIn,
    );
  }
}
