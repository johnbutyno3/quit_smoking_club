import 'dart:async';

import 'package:flutter/material.dart';

import '../engines/reading_engine.dart';
import '../l10n/app_localizations.dart';
import '../models/reading_book.dart';
import '../models/reading_chapter.dart';

class ReadingReaderPage extends StatefulWidget {
  const ReadingReaderPage({super.key, required this.book});

  final ReadingBook book;

  @override
  State<ReadingReaderPage> createState() => _ReadingReaderPageState();
}

class _ReadingReaderPageState extends State<ReadingReaderPage> {
  final ReadingEngine _engine = ReadingEngine();
  Timer? _timer;
  var _chapterIndex = 0;

  @override
  void initState() {
    super.initState();
    _openCurrentChapter();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openCurrentChapter() => _engine.openChapter(_chapter);

  Future<void> _continue() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await _engine.continueChapter(
      book: widget.book,
      chapter: _chapter,
    );
    if (!mounted) return;
    if (result.status == ChapterCompletionStatus.tooEarly) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.readingWaitSeconds(result.remainingSeconds)),
        ),
      );
      return;
    }
    if (_chapterIndex + 1 == widget.book.chapters.length) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.readingCompletedArticle)));
      return;
    }
    setState(() => _chapterIndex++);
    _openCurrentChapter();
  }

  ReadingChapter get _chapter => widget.book.chapters[_chapterIndex];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = _engine.remainingSeconds(_chapter);
    final isLastChapter = _chapterIndex + 1 == widget.book.chapters.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _chapter.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.readingChapterProgress(
                  _chapterIndex + 1,
                  widget.book.chapters.length,
                ),
              ),
              const Divider(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _chapter.content,
                    style: const TextStyle(fontSize: 18, height: 1.8),
                  ),
                ),
              ),
              Text(
                remaining == 0
                    ? l10n.readingCanContinue
                    : l10n.readingMinSeconds(remaining),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  child: Text(
                    isLastChapter
                        ? l10n.readingFinish
                        : l10n.readingContinueNextChapter,
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
