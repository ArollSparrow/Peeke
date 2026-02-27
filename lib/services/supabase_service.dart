import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  late final SupabaseClient supabase;

  // ==================== MOCK KEYS - REPLACE THESE ====================
  static const String supabaseUrl = 'https://ggvdgkaptatlfepgnjkx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdndmRna2FwdGF0bGZlcGduamt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyMDUzMzYsImV4cCI6MjA4Nzc4MTMzNn0.wxZ69PRzaSarw4b7-XWAAH0i0vNmpl-vTdgpCMRBfVQ';
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
