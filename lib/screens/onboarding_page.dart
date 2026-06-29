import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageCtrl = PageController();

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: "28");
  final _yearsCtrl = TextEditingController(text: "8");
  final _countCtrl = TextEditingController(text: "5");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F5),
      body: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSplash(),
            _buildTutorial(),
            _buildLogin(),
            _buildProfile(),
          ],
        ),
      ),
    );
  }

  Widget _buildSplash() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.spa, size: 64, color: Colors.green),
          ),
          const SizedBox(height: 20),
          const Text(
            "戒菸俱樂部",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          const Text("系統檢查更新中..."),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _pageCtrl.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Text("進入俱樂部"),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorial() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "APP 核心特色",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard(Icons.timer, "核心戒菸計畫"),
          _buildInfoCard(Icons.health_and_safety, "SOS 危機緩解艙"),
          _buildInfoCard(Icons.monetization_on, "累積時間賺金幣"),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _pageCtrl.animateToPage(
              2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Text("下一步：帳號設定"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "建立帳號與登入",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(labelText: "帳號"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "密碼"),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _pageCtrl.animateToPage(
              3,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
            child: const Text("註冊並繼續"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          const Text(
            "建立基本資料",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildInput(_nameCtrl, "您的姓名", Icons.badge, TextInputType.text),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  _ageCtrl,
                  "年齡",
                  Icons.cake,
                  TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInput(
                  _yearsCtrl,
                  "菸齡",
                  Icons.history,
                  TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInput(
            _countCtrl,
            "每日抽菸數",
            Icons.smoking_rooms,
            TextInputType.number,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final name = _nameCtrl.text.isEmpty ? "User" : _nameCtrl.text;
              final count = int.tryParse(_countCtrl.text) ?? 5;
              final age = int.tryParse(_ageCtrl.text) ?? 28;
              final years = int.tryParse(_yearsCtrl.text) ?? 8;

              await StorageService.saveUserName(name);
              await StorageService.saveDailyCount(count);
              await StorageService.saveUserAge(age);
              await StorageService.saveUserYears(years);

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }
            },
            child: const Text("進入主頁面"),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon,
    TextInputType type,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
