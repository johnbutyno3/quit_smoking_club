import '../models/coin_transaction.dart';
import '../services/storage_service.dart';

class StorageRepository {
  Future<bool> getIntroShown() async => await StorageService.getIntroShown();

  Future<String> getUserName() async => await StorageService.getUserName();
  Future<void> saveUserName(String name) async =>
      await StorageService.saveUserName(name);

  Future<int> getDailyCount() async => await StorageService.getDailyCount();
  Future<void> saveDailyCount(int count) async =>
      await StorageService.saveDailyCount(count);

  Future<int> getCoins() async => await StorageService.getCoins();
  Future<void> saveCoins(int coins) async =>
      await StorageService.saveCoins(coins);

  Future<bool> getPremium() async => await StorageService.getPremium();
  Future<void> savePremium(bool isPremium) async =>
      await StorageService.savePremium(isPremium);

  Future<void> saveSmokeRecords(List<DateTime> records) async =>
      await StorageService.saveSmokeRecords(records);
  Future<List<DateTime>> getSmokeRecordsForToday() async =>
      await StorageService.getSmokeRecordsForToday();

  Future<String> getFirstSmokeTime() async =>
      await StorageService.getFirstSmokeTime();
  Future<String> getLastSmokeTime() async =>
      await StorageService.getLastSmokeTime();

  Future<int> getCigarettePrice() async =>
      await StorageService.getCigarettePrice();

  Future<String> getPlanStartDate() async =>
      await StorageService.getPlanStartDate();

  Future<int> getPlanDurationDays() async =>
      await StorageService.getPlanDurationDays();

  Future<void> saveDayActual(String dateKey, int count) async =>
      await StorageService.saveDayActual(dateKey, count);
  Future<int> getDayActual(String dateKey) async =>
      await StorageService.getDayActual(dateKey);

  Future<int> getLoginStreak() async => await StorageService.getLoginStreak();
  Future<void> saveLastResetDate(String date) async =>
      await StorageService.saveLastResetDate(date);
  Future<String> getLastResetDate() async =>
      await StorageService.getLastResetDate();

  Future<void> saveFirstSmokeTime(String time) async =>
      await StorageService.saveFirstSmokeTime(time);
  Future<void> saveLastSmokeTime(String time) async =>
      await StorageService.saveLastSmokeTime(time);

  Future<List<CoinTransaction>> getCoinHistory() async =>
      await StorageService.getCoinHistory();

  Future<List<String>> getClaimedAchievements() async =>
      await StorageService.getClaimedAchievements();
  Future<void> saveClaimedAchievement(String achievementId) async =>
      await StorageService.saveClaimedAchievement(achievementId);

  Future<void> saveIntroShown(bool shown) async =>
      await StorageService.saveIntroShown(shown);

  Future<void> saveCigarettePrice(int price) async =>
      await StorageService.saveCigarettePrice(price);
  Future<void> savePlanStartDate(String date) async =>
      await StorageService.savePlanStartDate(date);
  Future<void> savePlanDurationDays(int days) async =>
      await StorageService.savePlanDurationDays(days);

  Future<int> getUserAge() async => await StorageService.getUserAge();
  Future<int> getUserYears() async => await StorageService.getUserYears();
  Future<void> saveUserAge(int years) async =>
      await StorageService.saveUserAge(years);
  Future<void> saveUserYears(int years) async =>
      await StorageService.saveUserYears(years);
}
