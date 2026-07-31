import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static String? get userId {
    return client.auth.currentUser?.id;
  }
}
