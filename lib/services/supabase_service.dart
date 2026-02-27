import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  late final SupabaseClient supabase;

  // ==================== MOCK KEYS - REPLACE THESE ====================
  static const String supabaseUrl = 'https://ggvdgkaptatlfepgnjkx.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_8Ay3cS37hk9_x55ZYbmjtg_h1P_C0Zh';
  // =================================================================

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    supabase = Supabase.instance.client;
    print('✅ Supabase connected on Web');
  }

  // Example methods (you can expand these)
  Future<Map<String, dynamic>> addClient(Map<String, dynamic> data) async {
    final response = await supabase.from('clients').insert(data).select().single();
    return response;
  }

  Future<List<dynamic>> getClients() async {
    final response = await supabase.from('clients').select();
    return response;
  }

  // Add more methods later (addSystem, getSystems, etc.)
}
