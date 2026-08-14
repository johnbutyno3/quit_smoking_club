import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'login_page.dart';
import 'app_gate.dart';

/// 首次開啟 App 時顯示的三頁滑動特色介紹
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  static const int _slideCount = 3;
  final _controller = PageController();
  int _current = 0;

  void _next() {
    if (_current < _slideCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishIntro();
    }
  }

  void _finishIntro() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => kRequireLogin ? const LoginPage() : const _HomeRedirect(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = [
      _Slide(
        icon: Icons.eco_outlined,
        title: l10n.introSlide1Title,
        desc: l10n.introSlide1Desc,
        color: const Color(0xFF1B5E20),
      ),
      _Slide(
        icon: Icons.calendar_month_outlined,
        title: l10n.introSlide2Title,
        desc: l10n.introSlide2Desc,
        color: const Color(0xFF2E7D32),
      ),
      _Slide(
        icon: Icons.people_outline,
        title: l10n.introSlide3Title,
        desc: l10n.introSlide3Desc,
        color: const Color(0xFF388E3C),
      ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishIntro,
                child: Text(
                  l10n.introSkip,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _SlideView(slide: slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _current == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _current == i
                        ? const Color(0xFF1B5E20)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _next,
                  child: Text(
                    _current == slides.length - 1
                        ? l10n.introGetStarted
                        : l10n.introNext,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HomeRedirect extends StatelessWidget {
  const _HomeRedirect();

  @override
  Widget build(BuildContext context) {
    return const _HomePageLoader();
  }
}

class _HomePageLoader extends StatelessWidget {
  const _HomePageLoader();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _Slide({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: slide.color.withAlpha(50),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(slide.icon, size: 60, color: slide.color),
            ),
            const SizedBox(height: 40),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: slide.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              slide.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
