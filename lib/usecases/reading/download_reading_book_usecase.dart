import '../../models/reading_book.dart';
import '../../models/reading_download_result.dart';
import '../../repositories/reading_repository.dart';

class DownloadReadingBookUseCase {
  DownloadReadingBookUseCase({ReadingRepository? repository})
    : _repository = repository ?? ReadingRepository();

  final ReadingRepository _repository;

  Future<ReadingDownloadResult> execute(ReadingBook book) {
    return _repository.downloadBook(book);
  }
}
