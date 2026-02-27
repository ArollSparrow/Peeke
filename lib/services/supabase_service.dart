import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  late final SupabaseClient supabase;

  // ==================== REPLACE WITH YOUR REAL KEYS ====================
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-real-anon-key';
  // =================================================================

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    supabase = Supabase.instance.client;
    print('✅ Supabase connected successfully on Web');
  }

  // ==================== CLIENT METHODS ====================
  Future<Map<String, dynamic>> addClient(Map<String, dynamic> clientData) async {
    final response = await supabase
        .from('clients')
        .insert(clientData)
        .select()
        .single();
    return response;
  }

  Future<List<dynamic>> getClients() async {
    final response = await supabase.from('clients').select();
    return response;
  }

  // ==================== SYSTEM METHODS ====================
  Future<Map<String, dynamic>> addSystem(Map<String, dynamic> systemData) async {
    final response = await supabase
        .from('systems')
        .insert(systemData)
        .select()
        .single();
    return response;
  }

  Future<List<dynamic>> getSystems() async {
    final response = await supabase.from('systems').select();
    return response;
  }

  // Add more methods later (operations, spare_parts, etc.)
}
