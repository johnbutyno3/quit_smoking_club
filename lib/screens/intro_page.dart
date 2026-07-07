import 'package:flutter/material.dart';
import 'login_page.dart';

/// 首次開啟 App 時顯示的三頁滑動特色介紹
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final _controller = PageController();
  int _current = 0;

  static const _slides = [
    _Slide(
      icon: Icons.eco_outlined,
      title: '開始你的戒菸之旅',
      desc: '科學化的戒菸計畫，幫助你一步一步減少菸量，直到完全戒斷。每一天都是勝利。',
      color: Color(0xFF1B5E20),
    ),
    _Slide(
      icon: Icons.calendar_month_outlined,
      title: '個人化排程計畫',
      desc: '根據你的抽菸習慣，系統自動生成最適合你的戒菸時間表，並即時追蹤進度。',
      color: Color(0xFF2E7D32),
    ),
    _Slide(
      icon: Icons.people_outline,
      title: '社群互助，不再孤單',
      desc: '加入戒菸社群，與同道人互相支持鼓勵。菸癮犯了？立即求救，大家都在。',
      color: Color(0xFF388E3C),
    ),
  ];

  void _next() {
    if (_current < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goLogin();
    }
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _goLogin,
                child: const Text(
                  '略過',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
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

            // Next / Start button
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
                    _current == _slides.length - 1 ? '開始使用' : '下一頁 ›',
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
