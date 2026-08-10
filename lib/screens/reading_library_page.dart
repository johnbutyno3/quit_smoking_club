import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/reading_book.dart';
import '../usecases/reading/download_reading_book_usecase.dart';
import '../usecases/reading/get_reading_books_usecase.dart';
import 'reading_reader_page.dart';

class ReadingLibraryPage extends StatefulWidget {
  const ReadingLibraryPage({super.key});

  @override
  State<ReadingLibraryPage> createState() => _ReadingLibraryPageState();
}

class _ReadingLibraryPageState extends State<ReadingLibraryPage> {
  final GetReadingBooksUseCase _getReadingBooksUseCase =
      GetReadingBooksUseCase();
  final DownloadReadingBookUseCase _downloadReadingBookUseCase =
      DownloadReadingBookUseCase();

  late Future<List<ReadingBook>> _books;

  String? _downloadingBookId;

  @override
  void initState() {
    super.initState();
    _books = _getReadingBooksUseCase.execute();
  }

  void _reload() {
    setState(() {
      _books = _getReadingBooksUseCase.execute();
    });
  }

  Future<void> _openBook(ReadingBook book) async {
    final cached = await _getReadingBooksUseCase.loadCachedBook(book.id);

    if (!mounted) return;

    if (cached != null) {
      await _openReader(cached);
      return;
    }

    setState(() {
      _downloadingBookId = book.id;
    });

    try {
      final result = await _downloadReadingBookUseCase.execute(book);

      if (!mounted) return;

      switch (result.status) {
        case ReadingDownloadStatus.downloaded:
        case ReadingDownloadStatus.alreadyCached:
          await _openReader(result.book!);

        case ReadingDownloadStatus.insufficientCoins:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.readingCoinInsufficient,
              ),
            ),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.downloadFailed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingBookId = null;
        });
      }
    }
  }

  Future<void> _openReader(ReadingBook book) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReadingReaderPage(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.readingTitle)),
      body: FutureBuilder<List<ReadingBook>>(
        future: _books,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? const <ReadingBook>[];

          if (books.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(l10n.readingEmpty),
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
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final book = books[index];
                final downloading = _downloadingBookId == book.id;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (book.author.isNotEmpty) Text(book.author),
                        if (book.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(book.description),
                        ],
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: downloading
                                ? null
                                : () => _openBook(book),
                            icon: downloading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.download_for_offline_outlined,
                                  ),
                            label: Text(
                              book.downloadCoinCost == 0
                                  ? l10n.downloadAndRead
                                  : '${book.downloadCoinCost} COIN ${l10n.downloadAndRead}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
