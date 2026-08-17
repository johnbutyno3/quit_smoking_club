import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'daily_schedule_page.dart';
import 'forum_page.dart';
import 'game_hub_page.dart';
import 'home_page.dart';
import 'mitigation_page.dart';
import 'reading_library_page.dart';
import 'youtube_library_page.dart';

/// V3 application shell. Owns the single Scaffold and the six-item navigation bar.
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = <Widget>[
      MitigationPage(title: l10n.cravingReliefChamberTitle),
      const ForumPage(),
      const ReadingLibraryPage(),
      const YouTubeLibraryPage(),
      const GameHubPage(),
      const DailySchedulePage(),
    ];
    final labels = <String>[
      l10n.sos,
      l10n.forum,
      l10n.readingArticleOfflineLabel,
      l10n.youtubeVideoLabel,
      l10n.gameHub,
      l10n.todaySmokingSchedule,
    ];
    final icons = <IconData>[
      Icons.sos,
      Icons.forum_outlined,
      Icons.article_outlined,
      Icons.video_library_outlined,
      Icons.sports_esports_outlined,
      Icons.calendar_today_outlined,
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          surface: Colors.white,
          surfaceContainer: Colors.white,
          surfaceContainerLow: const Color(0xFFF7F9F8),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _index < 0 ? 0 : _index + 1,
          children: <Widget>[
            const HomePage(),
            ...pages,
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(labels.length, (index) {
                  final selected = _index == index;
                  final color = selected
                      ? const Color(0xFF1B5E20)
                      : Colors.grey.shade600;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _index = index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icons[index], size: 21, color: color),
                            const SizedBox(height: 2),
                            Flexible(
                              child: Text(
                                labels[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1.1,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
