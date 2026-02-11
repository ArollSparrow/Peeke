// lib/screens/registration/select_system_screen_complete.dart
// COMPLETE translation of SelectRegistrationSystemScreen from registration.py
// Part 4/5: Select System with scrollable data table, search, and export

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';

class SelectSystemScreen extends StatefulWidget {
  const SelectSystemScreen({Key? key}) : super(key: key);

  @override
  State<SelectSystemScreen> createState() => _SelectSystemScreenState();
}

class _SelectSystemScreenState extends State<SelectSystemScreen> {
  final _searchController = TextEditingController();
  
  // State variables
  int? _selectedId;
  int? _selectedIndex;
  List<Map<String, dynamic>> _allResults = [];
  
  // Column configuration - equivalent to Python col_widths, headers, keys
  final List<double> _colWidths = [50, 110, 90, 90, 80, 120, 110, 90];
  final List<String> _headers = [
    'ID', 'Client', 'Location', 'Site', 'Type', 'Serial', 'Model', 'Capacity'
  ];
  final List<String> _keys = [
    'id', 'client', 'location', 'site', 'type', 'serial', 'model', 'capacity'
  ];
  
  // Computed total width for horizontal scrolling
  late double _totalContentWidth;

  @override
  void initState() {
    super.initState();
    _calculateTotalWidth();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== INITIALIZATION ====================
  
  /// Calculate total content width for horizontal scrolling
  void _calculateTotalWidth() {
    _totalContentWidth = _colWidths.reduce((a, b) => a + b) + 
                         16 + // padding left/right 8 each
                         4 * (_colWidths.length - 1); // spacing between columns
  }

  // ==================== DATA LOADING ====================
  
  /// Equivalent to load_data() - loads systems from database
  Future<void> _loadData([String query = '']) async {
    try {
      final results = await DatabaseService.instance.searchSystems(query);
      
      setState(() {
        _allResults = results.map((r) {
          // Parse capacity
          final capacityValue = r['capacity'] ?? '';
          final capacityUnit = r['capacity_unit'] ?? '';
          final capacityStr = capacityValue != '' && capacityUnit != ''
              ? '$capacityValue $capacityUnit'
              : capacityValue != '' ? capacityValue.toString()
              : '';
          
          return {
            'id': r['id']?.toString() ?? '',
            'client': r['client_name'] ?? '',
            'location': r['client_location'] ?? '',
            'site': r['client_site'] ?? '',
            'type': r['type'] ?? '',
            'serial': r['serial_number'] ?? '',
            'model': r['model'] ?? '',
            'capacity': capacityStr,
            'system_id': r['id'],
          };
        }).toList();
        
        // Reset selection
        _selectedId = null;
        _selectedIndex = null;
      });
    } catch (e) {
      debugPrint('Error loading systems: $e');
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error loading systems: $e', isError: true);
      }
    }
  }

  /// Equivalent to on_pre_enter() - loads data when screen enters
  void _onScreenEnter() {
    _loadData(_searchController.text.trim());
  }

  /// Equivalent to on_search() - handles search text changes
  void _onSearch(String value) {
    _loadData(value.trim());
  }

  /// Equivalent to refresh_data() - clears search and reloads
  void _refreshData() {
    _searchController.clear();
    _loadData('');
  }

  // ==================== ROW SELECTION ====================
  
  /// Equivalent to on_row_touch() - handles row selection
  void _selectRow(int index, int systemId) {
    setState(() {
      if (_selectedIndex == index) {
        // Deselect
        _selectedIndex = null;
        _selectedId = null;
      } else {
        // Select
        _selectedIndex = index;
        _selectedId = systemId;
        AppUtils.showSnackbar(context, 'Selected System ID: $systemId');
      }
    });
  }

  // ==================== NAVIGATION ====================
  
  /// Equivalent to go_update() - navigates to update screen
  Future<void> _goUpdate() async {
    if (_selectedId == null) return;
    
    final result = await Navigator.pushNamed(
      context,
      '/update_system',
      arguments: _selectedId,
    );
    
    // Reload data if update was successful
    if (result == true) {
      _loadData(_searchController.text.trim());
    }
  }

  /// Equivalent to go_delete() - navigates to delete screen
  Future<void> _goDelete() async {
    if (_selectedId == null) return;
    
    final result = await Navigator.pushNamed(
      context,
      '/delete_system',
      arguments: _selectedId,
    );
    
    // Reload data if delete was successful
    if (result == true) {
      _loadData(_searchController.text.trim());
    }
  }

  // ==================== EXPORT FUNCTIONS ====================
  
  /// Equivalent to show_export_menu() - shows export options
  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.accent),
              title: const Text('Export CSV', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _exportCsv();
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: AppColors.accent),
              title: const Text('Export JSON', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _exportJson();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Equivalent to export_csv() - exports data as CSV
  void _exportCsv() {
    if (_allResults.isEmpty) {
      AppUtils.showSnackbar(context, 'No data to export');
      return;
    }

    try {
      final buffer = StringBuffer();
      
      // Header row
      buffer.writeln(_headers.join(','));
      
      // Data rows
      for (final result in _allResults) {
        final row = _keys.map((key) {
          final value = result[key]?.toString() ?? '';
          // Escape commas and quotes
          if (value.contains(',') || value.contains('"')) {
            return '"${value.replaceAll('"', '""')}"';
          }
          return value;
        }).join(',');
        buffer.writeln(row);
      }
      
      // In a real app, you'd save this to a file or share it
      debugPrint('CSV Export:\n${buffer.toString()}');
      
      AppUtils.showSnackbar(
        context,
        'CSV generated with ${_allResults.length} records',
      );
    } catch (e) {
      debugPrint('CSV export error: $e');
      AppUtils.showSnackbar(context, 'Export failed: $e', isError: true);
    }
  }

  /// Equivalent to export_json() - exports data as JSON
  void _exportJson() {
    if (_allResults.isEmpty) {
      AppUtils.showSnackbar(context, 'No data to export');
      return;
    }

    try {
      final jsonData = _allResults.map((result) {
        return {
          'id': result['id'],
          'client': result['client'],
          'location': result['location'],
          'site': result['site'],
          'type': result['type'],
          'serial': result['serial'],
          'model': result['model'],
          'capacity': result['capacity'],
        };
      }).toList();
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      
      // In a real app, you'd save this to a file or share it
      debugPrint('JSON Export:\n$jsonString');
      
      AppUtils.showSnackbar(
        context,
        'JSON generated with ${_allResults.length} records',
      );
    } catch (e) {
      debugPrint('JSON export error: $e');
      AppUtils.showSnackbar(context, 'Export failed: $e', isError: true);
    }
  }

  // ==================== ROW BUILDER ====================
  
  /// Equivalent to create_row() - builds a data row widget
  Widget _buildRow(Map<String, dynamic> data, int index) {
    final isSelected = _selectedIndex == index;
    final systemId = data['system_id'] as int;
    
    return GestureDetector(
      onTap: () => _selectRow(index, systemId),
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4D667A) // Selected color
              : index % 2 == 0
                  ? const Color(0xFF2E2E33) // Even row
                  : const Color(0xFF383840), // Odd row
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: List.generate(_keys.length, (i) {
            final key = _keys[i];
            final width = _colWidths[i];
            final value = data[key]?.toString() ?? '';
            
            return Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }),
        ),
      ),
    );
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Header with search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Column(
              children: [
                // Title
                Text(
                  'Select System',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search row
                Row(
                  children: [
                    Expanded(
                      child: RoundedTextField(
                        hint: 'Search by serial, model, client...',
                        controller: _searchController,
                        onChanged: _onSearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.accent),
                      onPressed: _refreshData,
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: AppColors.accent),
                      onPressed: _showExportMenu,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Count label
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Found ${_allResults.length} systems',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Table header (scrollable horizontally)
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: _totalContentWidth,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF333338),
                ),
                child: Row(
                  children: List.generate(_headers.length, (i) {
                    return Container(
                      width: _colWidths[i],
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        _headers[i],
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          
          // Data table (scrollable vertically and horizontally)
          Expanded(
            child: _allResults.isEmpty
                ? Center(
                    child: Text(
                      'No systems found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: _totalContentWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Column(
                          children: List.generate(
                            _allResults.length,
                            (index) => _buildRow(_allResults[index], index),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          
          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedId != null ? _goUpdate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('UPDATE'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedId != null ? _goDelete : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
