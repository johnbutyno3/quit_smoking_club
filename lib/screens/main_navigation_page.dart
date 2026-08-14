import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'daily_schedule_page.dart';
import 'forum_page.dart';
import 'game_hub_page.dart';
import 'home_page.dart';
import 'mitigation_page.dart';
import 'reading_library_page.dart';
import 'youtube_library_page.dart';

/// V3 application shell.
/// Home is the landing page. The bottom bar contains exactly six secondary destinations.
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index = -1;

  void _goHome() => setState(() => _index = -1);

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

    return Scaffold(
      body: _index < 0 ? const HomePage() : pages[_index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(labels.length, (index) {
                final selected = _index == index;
                final color = selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant;
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
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
    );
  }
}
