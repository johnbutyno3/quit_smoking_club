import '../../models/coin_transaction.dart';
import '../../repositories/storage_repository.dart';

class StorageFacadeUseCase {
  static final StorageRepository _repository = StorageRepository();
  static Future<bool> getIntroShown() async =>
      await _repository.getIntroShown();

  static Future<String> getUserName() async => await _repository.getUserName();
  static Future<void> saveUserName(String name) async =>
      await _repository.saveUserName(name);

  static Future<int> getDailyCount() async => await _repository.getDailyCount();
  static Future<void> saveDailyCount(int v) async =>
      await _repository.saveDailyCount(v);

  static Future<int> getCoins() async => await _repository.getCoins();
  static Future<void> saveCoins(int v) async => await _repository.saveCoins(v);

  static Future<bool> getPremium() async => await _repository.getPremium();
  static Future<void> savePremium(bool v) async =>
      await _repository.savePremium(v);

  static Future<void> saveSmokeRecords(List<DateTime> records) async =>
      await _repository.saveSmokeRecords(records);

  static Future<List<DateTime>> getSmokeRecordsForToday() async =>
      await _repository.getSmokeRecordsForToday();

  static Future<String> getFirstSmokeTime() async =>
      await _repository.getFirstSmokeTime();
  static Future<String> getLastSmokeTime() async =>
      await _repository.getLastSmokeTime();

  static Future<int> getCigarettePrice() async =>
      await _repository.getCigarettePrice();

  static Future<String> getPlanStartDate() async =>
      await _repository.getPlanStartDate();

  static Future<int> getPlanDurationDays() async =>
      await _repository.getPlanDurationDays();

  static Future<void> saveDayActual(String dateKey, int count) async =>
      await _repository.saveDayActual(dateKey, count);

  static Future<int> getDayActual(String dateKey) async =>
      await _repository.getDayActual(dateKey);

  static Future<int> getLoginStreak() async =>
      await _repository.getLoginStreak();
  static Future<void> saveLastResetDate(String date) async =>
      await _repository.saveLastResetDate(date);
  static Future<String> getLastResetDate() async =>
      await _repository.getLastResetDate();

  static Future<void> saveFirstSmokeTime(String v) async =>
      await _repository.saveFirstSmokeTime(v);
  static Future<void> saveLastSmokeTime(String v) async =>
      await _repository.saveLastSmokeTime(v);

  static Future<List<CoinTransaction>> getCoinHistory() async =>
      await _repository.getCoinHistory();

  static Future<List<String>> getClaimedAchievements() async =>
      await _repository.getClaimedAchievements();

  static Future<void> saveClaimedAchievement(String achievementId) async =>
      await _repository.saveClaimedAchievement(achievementId);

  static Future<void> saveIntroShown(bool shown) async =>
      await _repository.saveIntroShown(shown);

  static Future<void> saveCigarettePrice(int v) async =>
      await _repository.saveCigarettePrice(v);
  static Future<void> savePlanStartDate(String v) async =>
      await _repository.savePlanStartDate(v);
  static Future<void> savePlanDurationDays(int v) async =>
      await _repository.savePlanDurationDays(v);

  static Future<int> getUserAge() async => await _repository.getUserAge();
  static Future<int> getUserYears() async => await _repository.getUserYears();
  static Future<void> saveUserAge(int v) async =>
      await _repository.saveUserAge(v);
  static Future<void> saveUserYears(int v) async =>
      await _repository.saveUserYears(v);
}
