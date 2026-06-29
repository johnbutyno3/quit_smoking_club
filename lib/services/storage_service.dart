import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // 💾 本地儲存：把每日抽菸數量存在手機裡
  static Future<void> saveDailyCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_count', count);
  }

  // 📡 本地讀取：App 開啟時，去手機撈出上次存的數量
  static Future<int> getDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('daily_count') ?? 5; // 沒存過就預設5支
  }

  // 💾 本地儲存：儲存使用者姓名
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  // 📡 本地讀取：撈出上次存的姓名
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? "User";
  }
}
