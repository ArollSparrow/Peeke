// lib/services/database_service.dart - COMPLETE DatabaseService
// Enhannced with all methods needed by registration screens

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('Database not available on web');
    if (_database != null) return _database!;
    _database = await _initDB('peekopv1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    // Clients table
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        site_name TEXT,
        location_coords TEXT,
        contact TEXT
      )
    ''');

    // Systems table
    await db.execute('''
      CREATE TABLE systems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        serial_number TEXT NOT NULL UNIQUE,
        model TEXT NOT NULL,
        capacity REAL NOT NULL,
        capacity_unit TEXT NOT NULL DEFAULT 'kW',
        barcode TEXT,
        installation_date TEXT NOT NULL,
        registration_date TEXT NOT NULL,
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    // Operations table
    await db.execute('''
      CREATE TABLE operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        system_id INTEGER NOT NULL,
        client_id INTEGER NOT NULL,
        operation_type TEXT NOT NULL,
        mode TEXT NOT NULL,
        date TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now')),
        paired_operation_id INTEGER,
        FOREIGN KEY(system_id) REFERENCES systems(id) ON DELETE CASCADE,
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    // Spare parts table
    await db.execute('''
      CREATE TABLE spare_parts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        part_name TEXT NOT NULL,
        part_number TEXT UNIQUE NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        unit TEXT NOT NULL,
        min_quantity INTEGER DEFAULT 0,
        location TEXT,
        notes TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // Inventory transactions table
    await db.execute('''
      CREATE TABLE inventory_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        part_id INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        system_id INTEGER,
        notes TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY(part_id) REFERENCES spare_parts(id) ON DELETE CASCADE,
        FOREIGN KEY(system_id) REFERENCES systems(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> init() async {
    await database;
  }

  // ==================== CLIENT OPERATIONS ====================
  
  Future<int> insertClient(Map<String, dynamic> client) async {
    final db = await instance.database;
    return await db.insert('clients', client);
  }

  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await instance.database;
    return await db.query('clients', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getClient(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getClientByName(String name) async {
    final db = await instance.database;
    final results = await db.query(
      'clients',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getClientBySite(String name, String siteName) async {
    final db = await instance.database;
    final results = await db.query(
      'clients',
      where: 'LOWER(name) = LOWER(?) AND LOWER(site_name) = LOWER(?)',
      whereArgs: [name, siteName],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateClient(int id, Map<String, dynamic> client) async {
    final db = await instance.database;
    return await db.update(
      'clients',
      client,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await instance.database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== SYSTEM OPERATIONS ====================
  
  Future<int> insertSystem(Map<String, dynamic> system) async {
    final db = await instance.database;
    return await db.insert('systems', system);
  }

  Future<List<Map<String, dynamic>>> getSystems({int? clientId}) async {
    final db = await instance.database;
    if (clientId != null) {
      return await db.query(
        'systems',
        where: 'client_id = ?',
        whereArgs: [clientId],
      );
    }
    return await db.query('systems');
  }

  Future<Map<String, dynamic>?> getSystem(int id) async {
    final db = await instance.database;
    final results = await db.query(
      'systems',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get system with joined client data (for display screens)
  Future<Map<String, dynamic>?> getSystemById(int systemId) async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT 
        s.id,
        s.client_id,
        s.type,
        s.serial_number,
        s.model,
        s.capacity,
        s.capacity_unit,
        s.barcode,
        s.installation_date,
        s.registration_date,
        c.name as client_name,
        c.location as client_location,
        c.site_name as client_site
      FROM systems s
      INNER JOIN clients c ON s.client_id = c.id
      WHERE s.id = ?
    ''', [systemId]);
    
    return results.isNotEmpty ? results.first : null;
  }

  /// Search systems with optional query filter
  Future<List<Map<String, dynamic>>> searchSystems([String? query]) async {
    final db = await instance.database;
    
    if (query == null || query.isEmpty) {
      return await db.rawQuery('''
        SELECT 
          s.id,
          c.name as client_name,
          c.location as client_location,
          c.site_name as client_site,
          s.type,
          s.serial_number,
          s.model,
          s.capacity,
          s.capacity_unit
        FROM systems s
        INNER JOIN clients c ON s.client_id = c.id
        ORDER BY s.id DESC
      ''');
    } else {
      return await db.rawQuery('''
        SELECT 
          s.id,
          c.name as client_name,
          c.location as client_location,
          c.site_name as client_site,
          s.type,
          s.serial_number,
          s.model,
          s.capacity,
          s.capacity_unit
        FROM systems s
        INNER JOIN clients c ON s.client_id = c.id
        WHERE 
          c.name LIKE ? OR 
          c.location LIKE ? OR 
          s.type LIKE ? OR 
          s.serial_number LIKE ? OR 
          s.model LIKE ?
        ORDER BY s.id DESC
      ''', List.filled(5, '%$query%'));
    }
  }

  Future<int> updateSystem(int id, Map<String, dynamic> system) async {
    final db = await instance.database;
    return await db.update(
      'systems',
      system,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSystem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'systems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERATIONS ====================
  
  Future<int> insertOperation(Map<String, dynamic> operation) async {
    final db = await instance.database;
    return await db.insert('operations', operation);
  }

  Future<List<Map<String, dynamic>>> getOperations({
    int? systemId,
    String? startDate,
    String? endDate,
  }) async {
    final db = await instance.database;
    String where = '';
    List<dynamic> whereArgs = [];

    if (systemId != null) {
      where += 'system_id = ?';
      whereArgs.add(systemId);
    }

    if (startDate != null && endDate != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'date BETWEEN ? AND ?';
      whereArgs.addAll([startDate, endDate]);
    }

    return await db.query(
      'operations',
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );
  }

  /// Get last operation for a system (for sequence validation)
  Future<Map<String, dynamic>?> getLastOperation(int systemId) async {
    final db = await instance.database;
    final results = await db.query(
      'operations',
      where: 'system_id = ?',
      whereArgs: [systemId],
      orderBy: 'date DESC, created_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get paired operations (start/stop pairs) for reports
  Future<List<Map<String, dynamic>>> getPairedOperations(
    String startDate,
    String endDate,
  ) async {
    final db = await instance.database;
    
    // Get all operations in date range with client and system details
    final operations = await db.rawQuery('''
      SELECT 
        o.id,
        o.system_id,
        o.client_id,
        o.operation_type,
        o.mode,
        o.date,
        o.data,
        o.created_at,
        o.updated_at,
        c.name as client_name,
        c.site_name,
        s.type as system_type,
        s.model,
        s.serial_number
      FROM operations o
      INNER JOIN clients c ON o.client_id = c.id
      INNER JOIN systems s ON o.system_id = s.id
      WHERE o.date BETWEEN ? AND ?
      ORDER BY o.system_id, o.date, o.created_at
    ''', [startDate, endDate]);

    // Pair START and STOP operations
    final paired = <Map<String, dynamic>>[];
    final Map<String, Map<String, dynamic>> pendingStarts = {};

    for (final op in operations) {
      final systemId = op['system_id'].toString();
      final opType = op['operation_type'];
      final mode = op['mode'];
      final key = '$systemId-$opType';

      if (mode == 'start') {
        pendingStarts[key] = op;
      } else if (mode == 'stop') {
        if (pendingStarts.containsKey(key)) {
          // Found a pair
          paired.add({
            'start': pendingStarts[key],
            'stop': op,
          });
          pendingStarts.remove(key);
        } else {
          // Unpaired stop
          paired.add({
            'start': null,
            'stop': op,
          });
        }
      } else {
        // Single mode operation
        paired.add({
          'start': op,
          'stop': null,
        });
      }
    }

    // Add remaining unpaired starts
    for (final startOp in pendingStarts.values) {
      paired.add({
        'start': startOp,
        'stop': null,
      });
    }

    return paired;
  }

  /// Delete operation by ID
  Future<int> deleteOperation(int operationId) async {
    final db = await instance.database;
    return await db.delete(
      'operations',
      where: 'id = ?',
      whereArgs: [operationId],
    );
  }

  // ==================== SPARE PARTS ====================
  
  Future<int> insertSparePart(Map<String, dynamic> sparePart) async {
    final db = await instance.database;
    return await db.insert('spare_parts', sparePart);
  }

  Future<List<Map<String, dynamic>>> getSpareParts() async {
    final db = await instance.database;
    return await db.query('spare_parts', orderBy: 'part_name ASC');
  }

  Future<int> updateSparePartQuantity(int partId, int quantity) async {
    final db = await instance.database;
    return await db.update(
      'spare_parts',
      {
        'quantity': quantity,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [partId],
    );
  }

  // ==================== GENERIC QUERY EXECUTOR ====================
  
  /// Generic query execution for custom queries
  Future<List<Map<String, dynamic>>> executeQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await instance.database;
    return await db.rawQuery(sql, arguments);
  }

  /// Generic insert/update/delete with commit
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    final db = await instance.database;
    await db.rawQuery(sql, arguments);
  }

  // ==================== DATABASE MANAGEMENT ====================
  
  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Get database file path
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbDirectory = Directory('${documentsDirectory.path}/Database');
    
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }
    
    return join(dbDirectory.path, 'peekopv1.db');
  }
}
