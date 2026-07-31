import 'dart:io';

import 'chapter_splitter.dart';
import 'json_exporter.dart';
import 'parser.dart';
import 'word_counter.dart';

Future<void> main() async {
  final inputDir = Directory('tools/importer/input');
  final outputDir = Directory('tools/importer/output');
  if (!inputDir.existsSync()) {
    stdout.writeln('No input directory found: ${inputDir.path}');
    return;
  }
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

  final files = inputDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.txt'))
      .toList();
  if (files.isEmpty) {
    stdout.writeln('No .txt files found in ${inputDir.path}');
    return;
  }

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    stdout.writeln('Importing: $name');
    final chapters = ChapterSplitter.split(await Parser.read(file));
    final output = JsonExporter.export(
      title: name.replaceFirst(RegExp(r'\.txt$', caseSensitive: false), ''),
      chapters: chapters.map((chapter) {
        final wordCount = WordCounter.count(chapter.content);
        return {
          'chapter': chapter.number,
          'title': chapter.title,
          'wordCount': wordCount,
          'effectiveSeconds': (wordCount / 4).ceil().clamp(20, 300),
          'content': chapter.content,
        };
      }).toList(),
    );
    final outputFile = File('${outputDir.path}/${name.replaceFirst(RegExp(r'\.txt$', caseSensitive: false), '.json')}');
    await outputFile.writeAsString(output);
    stdout.writeln('Wrote: ${outputFile.path}');
  }
  stdout.writeln('Import complete.');
}
