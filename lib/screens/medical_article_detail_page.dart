import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/medical/medical_article.dart';

class MedicalArticleDetailPage extends StatelessWidget {
  const MedicalArticleDetailPage({super.key, required this.article});

  final MedicalArticle article;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.coverImage.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      article.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (article.isVip)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.medicalVip,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                article.summary.isNotEmpty
                    ? article.summary
                    : l10n.medicalSummaryUnavailable,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Divider(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    article.body.isNotEmpty
                        ? article.body
                        : l10n.medicalSummaryUnavailable,
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
