import '../services/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository({UserService? service}) : _service = service ?? UserService();

  Future<String> registerWithEmail(String email, String password) async {
    return await _service.registerWithEmail(email, password);
  }

  Future<String> signInWithEmail(String email, String password) async {
    return await _service.signInWithEmail(email, password);
  }

  Future<String> signInWithGoogle() async {
    return await _service.signInWithGoogle();
  }

  Future<void> signOut() async {
    return await _service.signOut();
  }

  Future<bool> isNameAvailable(String name, {String? excludeUid}) async {
    return await _service.isNameAvailable(name, excludeUid: excludeUid);
  }

  Future<void> reserveName(String uid, String name, {String? oldName}) async {
    return await _service.reserveName(uid, name, oldName: oldName);
  }

  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    return await _service.loadProfile(uid);
  }

  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {
    return await _service.saveProfile(uid, data);
  }

  Future<void> syncCloudToLocal(String uid) async {
    return await _service.syncCloudToLocal(uid);
  }

  Future<void> syncLocalToCloud(String uid) async {
    return await _service.syncLocalToCloud(uid);
  }

  String? get googleDisplayName => _service.googleDisplayName;

  static String? get currentUid => UserService.currentUid;
  static set currentUid(String? uid) => UserService.currentUid = uid;

  static String? validateNameFormat(String name) {
    return UserService.validateNameFormat(name);
  }
}
