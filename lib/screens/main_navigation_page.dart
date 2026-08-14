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
/// Home is the landing page. The bottom bar contains exactly the six
/// secondary destinations requested by the product design.
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

    final body = _index < 0
        ? const HomePage()
        : pages[_index];

    return Scaffold(
      body: body,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
              ),
            ),
          ),
          child: Row(
            children: List.generate(labels.length, (index) {
              final selected = _index == index;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _index = index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icons[index],
                          size: 22,
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          labels[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
    );
  }
}
