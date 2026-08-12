import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  /// The app uses Firebase Auth as the identity source.
  /// Supabase is the data backend for public/community data, so records
  /// stored in Supabase carry the Firebase UID explicitly.
  static String? get userId {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
