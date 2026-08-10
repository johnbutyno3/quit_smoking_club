import '../../models/reading_book.dart';
import '../../repositories/reading_repository.dart';

class GetReadingBooksUseCase {
  GetReadingBooksUseCase({ReadingRepository? repository})
    : _repository = repository ?? ReadingRepository();

  final ReadingRepository _repository;

  Future<List<ReadingBook>> execute({String? language}) {
    return _repository.listBooks(language: language);
  }
}
