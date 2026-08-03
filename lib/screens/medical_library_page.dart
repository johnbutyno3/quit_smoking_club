import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/medical/medical_article.dart';
import '../repositories/medical_repository.dart';
import '../widgets/medical/medical_article_card.dart';

class MedicalLibraryPage extends StatefulWidget {
  const MedicalLibraryPage({super.key});

  @override
  State<MedicalLibraryPage> createState() => _MedicalLibraryPageState();
}

class _MedicalLibraryPageState extends State<MedicalLibraryPage> {
  final MedicalRepository _repository = MedicalRepository();

  late Future<List<MedicalArticle>> _articles;

  @override
  void initState() {
    super.initState();
    _articles = _repository.getMedicalArticles();
  }

  void _reload() {
    setState(() {
      _articles = _repository.getMedicalArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalLibraryTitle)),
      body: FutureBuilder<List<MedicalArticle>>(
        future: _articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(l10n.medicalLibraryLoadFailed),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: Text(l10n.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          final articles = snapshot.data ?? const <MedicalArticle>[];

          if (articles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_hospital_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(l10n.medicalLibraryEmpty),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _reload,
                      child: Text(l10n.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final article = articles[index];
                return MedicalArticleCard(article: article);
              },
            ),
          );
        },
      ),
    );
  }
}
