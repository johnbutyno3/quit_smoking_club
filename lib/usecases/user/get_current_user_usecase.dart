import '../../services/storage_service.dart';
import 'user_facade_usecase.dart';

class GetCurrentUserUseCase {
  String? executeUid() {
    return UserFacadeUseCase.currentUid;
  }

  Future<String?> executeName() {
    return StorageService.getUserName();
  }
}
