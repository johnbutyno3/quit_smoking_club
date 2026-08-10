enum ReadingDownloadStatus { downloaded, alreadyCached, insufficientCoins }

class ReadingDownloadResult {
  const ReadingDownloadResult(this.status, {this.book});

  final ReadingDownloadStatus status;
  final ReadingBook? book;

  bool get isAvailable => book != null;
}
