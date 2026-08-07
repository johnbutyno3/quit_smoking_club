import '../../repositories/user_repository.dart';

class UserFacadeUseCase {
  final UserRepository _repository;

  UserFacadeUseCase({UserRepository? repository})
    : _repository = repository ?? UserRepository();

  Future<String> registerWithEmail(String email, String password) async {
    return await _repository.registerWithEmail(email, password);
  }

  Future<String> signInWithEmail(String email, String password) async {
    return await _repository.signInWithEmail(email, password);
  }

  Future<String> signInWithGoogle() async {
    return await _repository.signInWithGoogle();
  }

  Future<void> signOut() async {
    return await _repository.signOut();
  }

  Future<bool> isNameAvailable(String name, {String? excludeUid}) async {
    return await _repository.isNameAvailable(name, excludeUid: excludeUid);
  }

  Future<void> reserveName(String uid, String name, {String? oldName}) async {
    return await _repository.reserveName(uid, name, oldName: oldName);
  }

  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    return await _repository.loadProfile(uid);
  }

  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    return await _repository.saveProfile(uid, data);
  }

  Future<void> syncCloudToLocal(String uid) async {
    return await _repository.syncCloudToLocal(uid);
  }

  Future<void> syncLocalToCloud(String uid) async {
    return await _repository.syncLocalToCloud(uid);
  }

  String? get googleDisplayName => _repository.googleDisplayName;

  static String? get currentUid => UserRepository.currentUid;
  static set currentUid(String? uid) => UserRepository.currentUid = uid;

  static String? validateNameFormat(String name) {
    return UserRepository.validateNameFormat(name);
  }
}
