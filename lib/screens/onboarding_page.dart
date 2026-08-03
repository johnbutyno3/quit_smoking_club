import 'package:flutter/material.dart';
import 'home_page.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardColors {
  static const primary = Color(0xFF1B5E20); // 質感墨綠
  static const bgTop = Color(0xFFE8F5E9); // 頂部嫩綠暈染
  static const bgBot = Colors.white; // 底部純白
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _countController.dispose();
    super.dispose();
  }

  // 💡 大綱 1.3 註冊登入與首次資料寫入硬碟邏輯
  Future<void> _submitAndStart() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final countStr = _countController.text.trim();
    final count = int.tryParse(countStr) ?? 5;

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.onboardingNameRequired)));
      return;
    }

    // 將資料安全寫入 StorageService 磁碟快取，解鎖首次下載流程
    await StorageService.saveUserName(name);
    await StorageService.saveDailyCount(count);
    await StorageService.savePremium(false); // 預設為一般會員

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {
        'title': l10n.onboardingFeature1Title,
        'desc': l10n.onboardingFeature1Desc,
      },
      {
        'title': l10n.onboardingFeature2Title,
        'desc': l10n.onboardingFeature2Desc,
      },
      {
        'title': l10n.onboardingFeature3Title,
        'desc': l10n.onboardingFeature3Desc,
      },
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_OnboardColors.bgTop, _OnboardColors.bgBot],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "QUIT SMOKING CLUB",
                  style: TextStyle(
                    color: _OnboardColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingWelcome,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 30),
                // 💡 1. 特色導覽卡滑動區塊
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: features.length,
                    onPageChanged: (int p) {
                      setState(() => _currentPage = p);
                    },
                    itemBuilder: (context, idx) {
                      final f = features[idx];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              f["title"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _OnboardColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              f["desc"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // 導覽頁小圓點進度條
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(features.length, (idx) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == idx ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == idx
                            ? _OnboardColors.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // 💡 2. 大綱 1.3 註冊登入：首次資料填寫區塊
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView(
                      children: [
                        Text(
                          l10n.onboardingCreateProfile,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _OnboardColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: l10n.onboardingNicknameInput,
                            labelStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _countController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.onboardingDailyTarget,
                            labelStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 💡 3. 一鍵儲存並前往主頁按鈕
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _OnboardColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _submitAndStart,
                          child: Text(
                            l10n.onboardingStartJourney,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
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
