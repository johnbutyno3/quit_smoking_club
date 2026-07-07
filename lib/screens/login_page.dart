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

class _LoginColors {
  static const primary = Color(0xFF1B5E20);
  static const accent = Color(0xFF4CAF50);
  static const bg = Color(0xFFE8F5E9);
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _error;

  // ── Google 登入 ─────────────────────────────────────────────────
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
        // 回來的使用者：同步雲端資料
        await service.syncCloudToLocal(uid);
        _goHome();
      } else {
        // 全新 Google 帳號：進入完整引導設定流程
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

  // ── 匿名繼續 ─────────────────────────────────────────────────────
  Future<void> _handleAnonymous() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = UserService();
      final uid = await service.signInAnonymously();
      final profile = await service.loadProfile(uid);

      if (profile != null) {
        await service.syncCloudToLocal(uid);
        _goHome();
      } else {
        // 全新使用者：進入完整引導設定流程
        _goOnboarding(service, uid);
      }
    } catch (e) {
      debugPrint('[LoginPage] Anonymous signIn error: $e');
      setState(() => _error = '登入失敗：$e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LoginColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: _LoginColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _LoginColors.primary.withAlpha(80),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smoke_free,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'QUIT SMOKING CLUB',
                  style: TextStyle(
                    color: _LoginColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '重獲健康，從今天開始',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 48),

                // Google 登入按鈕
                _AuthButton(
                  onTap: _isLoading ? null : _handleGoogleSignIn,
                  icon: Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.login, size: 22),
                  ),
                  label: '以 Google 帳號登入',
                  bgColor: Colors.white,
                  textColor: Colors.black87,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 14),

                // 匿名按鈕
                _AuthButton(
                  onTap: _isLoading ? null : _handleAnonymous,
                  icon: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: '跳過登入，匿名使用',
                  bgColor: _LoginColors.accent,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20),

                if (_isLoading)
                  const CircularProgressIndicator(color: _LoginColors.primary),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 32),
                const Text(
                  '登入即表示您同意本應用程式的服務條款與隱私政策。\n匿名帳號無法跨裝置恢復資料。',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 共用登入按鈕元件 ─────────────────────────────────────────────────
class _AuthButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;

  const _AuthButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        elevation: borderColor == null ? 2 : 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: borderColor != null
                ? BoxDecoration(
                    border: Border.all(color: borderColor!),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
