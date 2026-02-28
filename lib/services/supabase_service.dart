import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  late final SupabaseClient supabase;

  // Reads from GitHub Secrets / Vercel Environment Variables
  final String supabaseUrl = const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-ref.supabase.co',
  );

  final String supabaseAnonKey = const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-real-anon-key-here',
  );

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    supabase = Supabase.instance.client;
    print('✅ Supabase connected successfully on Web');
  }

  // ==================== CLIENTS ====================
  Future<Map<String, dynamic>> addClient(Map<String, dynamic> data) async {
    final response = await supabase.from('clients').insert(data).select().single();
    return response;
  }

  Future<List<dynamic>> getClients() async {
    final response = await supabase.from('clients').select();
    return response;
  }

  // ==================== SYSTEMS ====================
  Future<Map<String, dynamic>> addSystem(Map<String, dynamic> data) async {
    final response = await supabase.from('systems').insert(data).select().single();
    return response;
  }

  Future<List<dynamic>> getSystems() async {
    final response = await supabase.from('systems').select();
    return response;
  }

  // ==================== OPERATIONS ====================
  Future<Map<String, dynamic>> addOperation(Map<String, dynamic> data) async {
    final response = await supabase.from('operations').insert(data).select().single();
    return response;
  }

  Future<List<dynamic>> getOperations() async {
    final response = await supabase.from('operations').select();
    return response;
  }

  // ==================== SPARE PARTS ====================
  Future<Map<String, dynamic>> addSparePart(Map<String, dynamic> data) async {
    final response = await supabase.from('spare_parts').insert(data).select().single();
    return response;
  }

  Future<List<dynamic>> getSpareParts() async {
    final response = await supabase.from('spare_parts').select();
    return response;
  }

  // ==================== INVENTORY ====================
  Future<Map<String, dynamic>> addInventoryTransaction(Map<String, dynamic> data) async {
    final response = await supabase.from('inventory_transactions').insert(data).select().single();
    return response;
  }

  // ==================== BACKUPS ====================
  Future<Map<String, dynamic>> addBackup(Map<String, dynamic> data) async {
    final response = await supabase.from('backups').insert(data).select().single();
    return response;
  }
}
