import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'daily_schedule_page.dart';
import 'forum_page.dart';
import 'game_hub_page.dart';
import 'mitigation_page.dart';
import 'reading_library_page.dart';
import 'youtube_library_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index = 0;

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
      'SOS',
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

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: List.generate(
          labels.length,
          (index) => NavigationDestination(
            icon: Icon(icons[index]),
            selectedIcon: Icon(icons[index]),
            label: labels[index],
          ),
        ),
      ),
    );
  }
}
