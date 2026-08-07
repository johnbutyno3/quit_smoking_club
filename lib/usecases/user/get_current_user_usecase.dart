import 'user_facade_usecase.dart';

class GetCurrentUserUseCase {
  String? executeUid() {
    return UserFacadeUseCase.currentUid;
  }
}
