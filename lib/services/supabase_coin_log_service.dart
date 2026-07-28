import 'supabase_service.dart';

class SupabaseCoinLogService {
  static Future<void> addLog({
    required String userId,
    required int amount,
    required String type,
    String? reason,
    String? referenceId,
  }) async {
    try {
      await SupabaseService.client.from('coin_logs').insert({
        'user_id': userId,
        'amount': amount,
        'type': type,
        'reason': reason ?? '',
        'reference_id': referenceId,
      });
    } catch (e) {
      rethrow;
    }
  }
}
