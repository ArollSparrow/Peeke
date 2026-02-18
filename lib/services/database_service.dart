import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._private();
  DatabaseService._private();

  Future<void> init() async {
    if (kIsWeb) {
      print('🕸️ Web mode → Database mocked (UI/UX & logic testing only)');
      return;
    }
    // Your original mobile SQLite code can go here later
  }

  // ==================== CLIENTS ====================
  Future<int> insertClient(Map<String, dynamic> client) async => kIsWeb ? 999 : 0;
  Future<List<Map<String, dynamic>>> getClients() async => kIsWeb ? [
    {'id': 1, 'name': 'Demo Client Nairobi', 'location': 'Nairobi', 'site_name': 'HQ'},
    {'id': 2, 'name': 'Demo Client Mombasa', 'location': 'Mombasa', 'site_name': 'Plant'},
  ] : [];
  Future<Map<String, dynamic>?> getClient(int id) async => kIsWeb ? null : null;
  Future<Map<String, dynamic>?> getClientByName(String name) async => kIsWeb ? null : null;
  Future<Map<String, dynamic>?> getClientBySite(String name, String siteName) async => kIsWeb ? null : null;
  Future<int> updateClient(int id, Map<String, dynamic> client) async => kIsWeb ? 0 : 0;
  Future<int> deleteClient(int id) async => kIsWeb ? 0 : 0;

  // ==================== SYSTEMS ====================
  Future<int> insertSystem(Map<String, dynamic> system) async => kIsWeb ? 999 : 0;
  Future<List<Map<String, dynamic>>> getSystems({int? clientId}) async => kIsWeb ? [] : [];
  Future<Map<String, dynamic>?> getSystem(int id) async => kIsWeb ? null : null;
  Future<Map<String, dynamic>?> getSystemById(int systemId) async => kIsWeb ? null : null;
  Future<List<Map<String, dynamic>>> searchSystems([String? query]) async => kIsWeb ? [] : [];
  Future<int> updateSystem(int id, Map<String, dynamic> system) async => kIsWeb ? 0 : 0;
  Future<int> deleteSystem(int id) async => kIsWeb ? 0 : 0;

  // ==================== OPERATIONS ====================
  Future<int> insertOperation(Map<String, dynamic> operation) async => kIsWeb ? 999 : 0;
  Future<List<Map<String, dynamic>>> getOperations({int? systemId, String? startDate, String? endDate}) async => kIsWeb ? [] : [];
  Future<Map<String, dynamic>?> getLastOperation(int systemId) async => kIsWeb ? null : null;
  Future<List<Map<String, dynamic>>> getPairedOperations(String startDate, String endDate) async => kIsWeb ? [] : [];
  Future<int> deleteOperation(int operationId) async => kIsWeb ? 0 : 0;

  // ==================== SPARE PARTS & INVENTORY ====================
  Future<int> insertSparePart(Map<String, dynamic> sparePart) async => kIsWeb ? 999 : 0;
  Future<List<Map<String, dynamic>>> getSpareParts() async => kIsWeb ? [] : [];
  Future<int> updateSparePartQuantity(int partId, int quantity) async => kIsWeb ? 0 : 0;

  // ==================== GENERIC ====================
  Future<List<Map<String, dynamic>>> executeQuery(String sql, [List? arguments]) async => kIsWeb ? [] : [];
  Future<void> execute(String sql, [List? arguments]) async {}
  Future<void> close() async {}
}
