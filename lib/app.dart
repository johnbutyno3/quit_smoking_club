import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/app_gate.dart';

class QuitSmokingApp extends StatelessWidget {
  const QuitSmokingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: l10n?.appTitle ?? 'Quit Smoking Club',

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      supportedLocales: AppLocalizations.supportedLocales,

      home: const AppGate(),
    );
  }
}
