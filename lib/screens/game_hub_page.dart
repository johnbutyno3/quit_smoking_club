import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'game_2048_page.dart';
import 'game_sudoku_page.dart';

class GameHubPage extends StatelessWidget {
  const GameHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final games = [
      _GameEntry(
        icon: Icons.grid_4x4,
        emoji: '🧩',
        title: '2048',
        subtitle: l10n.game2048Subtitle,
        color: const Color(0xFFEDC22E),
        bgColor: const Color(0xFFFFF8E1),
      ),
      const _GameEntry(
        icon: Icons.grid_3x3,
        emoji: '🔢',
        title: 'Sudoku',
        subtitle: 'Classic 9×9 number puzzle',
        color: Color(0xFF43A047),
        bgColor: Color(0xFFE8F5E9),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('🎮 ${l10n.gameHub}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.gameHubBannerTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(l10n.gameHubBannerSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(l10n.gameHubSelectGame, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return _GameCard(game: game, onTap: () => _launchGame(context, game));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _launchGame(BuildContext context, _GameEntry game) {
    final Widget? page = switch (game.title) {
      '2048' => const Game2048Page(),
      'Sudoku' => const SudokuPage(),
      _ => null,
    };
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }
}

class _GameCard extends StatelessWidget {
  final _GameEntry game;
  final VoidCallback onTap;

  const _GameCard({required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: game.color.withAlpha(80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [game.bgColor, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: game.color.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: game.color.withAlpha(80), width: 1.5),
                ),
                child: Center(child: Text(game.emoji, style: const TextStyle(fontSize: 32))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(game.subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF1B5E20).withAlpha(20), borderRadius: BorderRadius.circular(20)),
                      child: Text(AppLocalizations.of(context)!.gameHubOfflineBuiltIn, style: const TextStyle(fontSize: 10, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameEntry {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;

  const _GameEntry({required this.icon, required this.emoji, required this.title, required this.subtitle, required this.color, required this.bgColor});
}
