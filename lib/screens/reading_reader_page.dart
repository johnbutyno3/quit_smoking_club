import 'dart:async';

import 'package:flutter/material.dart';

import '../engines/reading_engine.dart';
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
    final result = await _engine.continueChapter(book: widget.book, chapter: _chapter);
    if (!mounted) return;
    if (result.status == ChapterCompletionStatus.tooEarly) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('請再閱讀 ${result.remainingSeconds} 秒後繼續。')),
      );
      return;
    }
    if (_chapterIndex + 1 == widget.book.chapters.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已完成這篇文章。')),
      );
      return;
    }
    setState(() => _chapterIndex++);
    _openCurrentChapter();
  }

  ReadingChapter get _chapter => widget.book.chapters[_chapterIndex];

  @override
  Widget build(BuildContext context) {
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
              Text(_chapter.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('第 ${_chapterIndex + 1} 章／共 ${widget.book.chapters.length} 章'),
              const Divider(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_chapter.content, style: const TextStyle(fontSize: 18, height: 1.8)),
                ),
              ),
              Text(
                remaining == 0 ? '可以繼續下一章' : '請閱讀至少 $remaining 秒',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  child: Text(isLastChapter ? '完成閱讀' : '繼續下一章'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
