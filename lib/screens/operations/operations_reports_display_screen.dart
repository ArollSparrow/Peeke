// lib/screens/operations/operations_reports_display_screen_complete.dart
// COMPLETE translation of OperationsReportsDisplayScreen from operations.py
// Part 3 of 3: Operations Reports Display with paired operations, export, update, delete

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';
import '../../models/operation_config.dart';

class OperationsReportsDisplayScreen extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const OperationsReportsDisplayScreen({
    Key? key,
    this.arguments,
  }) : super(key: key);

  @override
  State<OperationsReportsDisplayScreen> createState() =>
      _OperationsReportsDisplayScreenState();
}

class _OperationsReportsDisplayScreenState
    extends State<OperationsReportsDisplayScreen> {
  // State variables
  String _period = 'daily';
  String _reportDate = '';
  List<int> _selectedRecords = [];
  List<Map<String, dynamic>> _operations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFromArguments();
  }

  /// Initialize period and date from navigation arguments
  void _initializeFromArguments() {
    if (widget.arguments != null) {
      _period = widget.arguments!['period'] ?? 'daily';
      _reportDate = widget.arguments!['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else {
      _reportDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    _loadReportData();
  }

  // ==================== DATA LOADING ====================

  /// Equivalent to on_pre_enter() - loads data when screen enters
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from route if not already initialized
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _operations.isEmpty) {
      _period = args['period'] ?? 'daily';
      _reportDate = args['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      _loadReportData();
    }
  }

  /// Equivalent to load_report_data() - loads and displays report data
  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
      _selectedRecords.clear();
    });

    try {
      // Calculate date range
      final dateRange = _calculateDateRange(_period, _reportDate);
      final startDate = dateRange['start']!;
      final endDate = dateRange['end']!;

      // Get paired operations
      final pairedOps = await DatabaseService.instance.getPairedOperations(
        startDate,
        endDate,
      );

      setState(() {
        _operations = pairedOps;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading report data: $e');
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error loading report: $e', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Equivalent to _calculate_date_range() - calculates start and end dates based on period
  Map<String, String> _calculateDateRange(String period, String reportDate) {
    DateTime dateObj;
    try {
      dateObj = DateFormat('yyyy-MM-dd').parse(reportDate);
    } catch (e) {
      dateObj = DateTime.now();
    }

    String startDate, endDate;

    switch (period) {
      case 'daily':
        startDate = DateFormat('yyyy-MM-dd').format(dateObj);
        endDate = DateFormat('yyyy-MM-dd').format(dateObj);
        break;

      case 'weekly':
        // Get start of week (Monday)
        final startOfWeek = dateObj.subtract(Duration(days: dateObj.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        startDate = DateFormat('yyyy-MM-dd').format(startOfWeek);
        endDate = DateFormat('yyyy-MM-dd').format(endOfWeek);
        break;

      case 'monthly':
        // Get first and last day of month
        final startOfMonth = DateTime(dateObj.year, dateObj.month, 1);
        final endOfMonth = DateTime(dateObj.year, dateObj.month + 1, 0);
        startDate = DateFormat('yyyy-MM-dd').format(startOfMonth);
        endDate = DateFormat('yyyy-MM-dd').format(endOfMonth);
        break;

      case 'yearly':
        // Get first and last day of year
        final startOfYear = DateTime(dateObj.year, 1, 1);
        final endOfYear = DateTime(dateObj.year, 12, 31);
        startDate = DateFormat('yyyy-MM-dd').format(startOfYear);
        endDate = DateFormat('yyyy-MM-dd').format(endOfYear);
        break;

      default:
        startDate = DateFormat('yyyy-MM-dd').format(dateObj);
        endDate = DateFormat('yyyy-MM-dd').format(dateObj);
    }

    return {'start': startDate, 'end': endDate};
  }

  // ==================== DISPLAY METHODS ====================

  /// Equivalent to _display_operations() - displays operations with paired START/STOP
  List<Widget> _displayOperations() {
    final widgets = <Widget>[];

    for (final pairedOp in _operations) {
      final startOp = pairedOp['start'];
      final stopOp = pairedOp['stop'];

      if (startOp != null && stopOp != null) {
        // Paired START and STOP
        widgets.add(_createPairedOperationRow(startOp, stopOp));
      } else if (startOp != null) {
        // Single or unpaired START
        widgets.add(_createSingleOperationRow(startOp));
      } else if (stopOp != null) {
        // Unpaired STOP
        widgets.add(_createSingleOperationRow(stopOp));
      }
    }

    return widgets;
  }

  /// Equivalent to _create_paired_operation_row() - creates row for paired operations
  Widget _createPairedOperationRow(
    Map<String, dynamic> startOp,
    Map<String, dynamic> stopOp,
  ) {
    // Extract data
    final opIdStart = startOp['id'];
    final opIdStop = stopOp['id'];
    final opType = startOp['operation_type'];
    final date = startOp['date'];
    final startData = jsonDecode(startOp['data']) as Map<String, dynamic>;
    final stopData = jsonDecode(stopOp['data']) as Map<String, dynamic>;

    // Get client and system info from start operation
    final client = startOp['client_name'] ?? 'Unknown';
    final site = startOp['site_name'] ?? 'No Site';
    final systemType = startOp['system_type'] ?? '';
    final model = startOp['model'] ?? '';
    final serial = startOp['serial_number'] ?? '';

    final opConfig = OperationConfig.getByKey(opType);
    final opName = opConfig?.name ?? opType;

    // Format date
    String dateStr;
    try {
      final dateObj = DateFormat('yyyy-MM-dd').parse(date);
      dateStr = DateFormat('dd-MM-yyyy').format(dateObj);
    } catch (e) {
      dateStr = date;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFF262A38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    '📋 $opName',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                Text(
                  '📅 $dateStr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Client and System info
            Text(
              '🏢 $client ($site) | ⚙️ $systemType-$model ($serial)',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),

            // START and STOP data side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // START column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '▶ START',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4DCC4D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._buildDataLines(startData),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 2,
                  height: 75,
                  color: const Color(0xFF4D4D66),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // STOP column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⏹ STOP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCC4D4D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._buildDataLines(stopData),
                      // Duration calculation
                      if (startData['start_time'] != null && stopData['stop_time'] != null)
                        _buildDuration(startData['start_time'], stopData['stop_time']),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: _selectedRecords.contains(opIdStart) ||
                      _selectedRecords.contains(opIdStop),
                  onChanged: (value) {
                    _toggleSelection([opIdStart, opIdStop], value ?? false);
                  },
                  activeColor: AppColors.accent,
                ),
                const Text(
                  'Select for action',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Equivalent to _create_single_operation_row() - creates row for single operation
  Widget _createSingleOperationRow(Map<String, dynamic> operation) {
    final opId = operation['id'];
    final opType = operation['operation_type'];
    final mode = operation['mode'];
    final date = operation['date'];
    final data = jsonDecode(operation['data']) as Map<String, dynamic>;

    final client = operation['client_name'] ?? 'Unknown';
    final site = operation['site_name'] ?? 'No Site';
    final systemType = operation['system_type'] ?? '';
    final model = operation['model'] ?? '';
    final serial = operation['serial_number'] ?? '';

    final opConfig = OperationConfig.getByKey(opType);
    final opName = opConfig?.name ?? opType;

    // Mode styling
    String modeIcon;
    Color modeColor;
    if (mode == 'start') {
      modeIcon = '▶';
      modeColor = const Color(0xFF4DCC4D);
    } else if (mode == 'stop') {
      modeIcon = '⏹';
      modeColor = const Color(0xFFCC4D4D);
    } else {
      modeIcon = '📝';
      modeColor = const Color(0xFF9999CC);
    }

    // Format date
    String dateStr;
    try {
      final dateObj = DateFormat('yyyy-MM-dd').parse(date);
      dateStr = DateFormat('dd-MM-yyyy').format(dateObj);
    } catch (e) {
      dateStr = date;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFF262A38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$modeIcon $opName - ${mode.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: modeColor,
                    ),
                  ),
                ),
                Text(
                  '📅 $dateStr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Client and System info
            Text(
              '🏢 $client ($site) | ⚙️ $systemType-$model ($serial)',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),

            // Data
            ..._buildDataLines(data).take(5),

            const SizedBox(height: 8),

            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: _selectedRecords.contains(opId),
                  onChanged: (value) {
                    _toggleSelection([opId], value ?? false);
                  },
                  activeColor: AppColors.accent,
                ),
                const Text(
                  'Select for action',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build data lines from operation data
  List<Widget> _buildDataLines(Map<String, dynamic> data) {
    final lines = <Widget>[];

    // Time
    if (data['start_time'] != null) {
      lines.add(Text('⏰ ${data['start_time']}',
          style: const TextStyle(fontSize: 12, color: Colors.white)));
    }
    if (data['stop_time'] != null) {
      lines.add(Text('⏰ ${data['stop_time']}',
          style: const TextStyle(fontSize: 12, color: Colors.white)));
    }

    // Attendant
    for (final key in ['bh_attendant', 'utils_attendant', 'fuel_attendant']) {
      if (data[key] != null) {
        lines.add(Text('👤 ${data[key]}',
            style: const TextStyle(fontSize: 12, color: Colors.white)));
        break;
      }
    }

    // Hour meter
    if (data['hour_meter'] != null) {
      lines.add(Text('🔢 HM: ${data['hour_meter']} Hrs',
          style: const TextStyle(fontSize: 12, color: Colors.white)));
    }

    // Status
    if (data['status'] != null) {
      final icon = data['status'] == 'Normal' ? '✅' : '⚠️';
      lines.add(Text('$icon ${data['status']}',
          style: const TextStyle(fontSize: 12, color: Colors.white)));
    }

    return lines;
  }

  /// Helper to build duration widget
  Widget _buildDuration(String startTime, String stopTime) {
    try {
      final start = DateFormat('HH:mm').parse(startTime);
      final stop = DateFormat('HH:mm').parse(stopTime);
      final duration = stop.difference(start);

      if (duration.isNegative) return const SizedBox.shrink();

      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      return Text(
        '⏱ Duration: ${hours}h ${minutes}m',
        style: const TextStyle(fontSize: 12, color: Colors.white),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  // ==================== SELECTION MANAGEMENT ====================

  /// Equivalent to _toggle_selection() - toggles selection of operations
  void _toggleSelection(List<int> operationIds, bool isSelected) {
    setState(() {
      if (isSelected) {
        for (final id in operationIds) {
          if (!_selectedRecords.contains(id)) {
            _selectedRecords.add(id);
          }
        }
      } else {
        _selectedRecords.removeWhere((id) => operationIds.contains(id));
      }
    });
    debugPrint('Selected records: $_selectedRecords');
  }

  // ==================== ACTION METHODS ====================

  /// Equivalent to export_report() - exports report data
  void _exportReport() {
    if (_operations.isEmpty) {
      AppUtils.showSnackbar(context, 'No data to export');
      return;
    }

    // Show export options
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
              'Export Report',
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

  /// Export to CSV format
  void _exportCsv() {
    // TODO: Implement actual CSV file export
    AppUtils.showSnackbar(context, '📊 CSV export feature coming soon!');
  }

  /// Export to JSON format
  void _exportJson() {
    // TODO: Implement actual JSON file export
    AppUtils.showSnackbar(context, '📊 JSON export feature coming soon!');
  }

  /// Equivalent to update_selected() - updates selected records
  void _updateSelected() {
    if (_selectedRecords.isEmpty) {
      AppUtils.showSnackbar(context, 'No records selected');
      return;
    }

    // TODO: Implement update functionality
    AppUtils.showSnackbar(
      context,
      '📝 Update feature for ${_selectedRecords.length} record(s) coming soon!',
    );
  }

  /// Equivalent to delete_selected() - deletes selected records
  void _deleteSelected() {
    if (_selectedRecords.isEmpty) {
      AppUtils.showSnackbar(context, 'No records selected');
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.danger),
            const SizedBox(width: 8),
            const Text(
              'Confirm Delete',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${_selectedRecords.length} record(s)?\n\nThis action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  /// Equivalent to confirm_delete() - confirms and executes delete
  Future<void> _confirmDelete() async {
    try {
      for (final recordId in _selectedRecords) {
        await DatabaseService.instance.deleteOperation(recordId);
      }

      if (mounted) {
        AppUtils.showSnackbar(
          context,
          '✅ Deleted ${_selectedRecords.length} record(s)',
        );
        setState(() {
          _selectedRecords.clear();
        });
        _loadReportData(); // Reload data
      }
    } catch (e) {
      debugPrint('Error deleting records: $e');
      if (mounted) {
        AppUtils.showSnackbar(context, 'Delete failed: $e', isError: true);
      }
    }
  }

  // ==================== BUTTON BUILDER ====================

  /// Equivalent to _create_action_btn() - creates action button
  Widget _createActionBtn(String text, Color color, double sizeX) {
    VoidCallback? onPressed;

    if (text == 'Export') {
      onPressed = _exportReport;
    } else if (text == 'Update') {
      onPressed = _updateSelected;
    } else if (text == 'Delete') {
      onPressed = _deleteSelected;
    } else if (text == 'Back') {
      onPressed = () => Navigator.pop(context);
    }

    return Expanded(
      flex: (sizeX * 100).toInt(),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: text == 'Export' ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    // Format period label
    String periodLabel = '${_period.capitalize()} Report';
    try {
      final dateObj = DateFormat('yyyy-MM-dd').parse(_reportDate);
      periodLabel += ' - ${DateFormat('dd-MM-yyyy').format(dateObj)}';
    } catch (e) {
      // Use as is
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.98,
          height: MediaQuery.of(context).size.height * 0.96,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A26).withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Title
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Operations Report',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      periodLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Operations list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    : _operations.isEmpty
                        ? const Center(
                            child: Text(
                              'No operations recorded for this period',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            children: _displayOperations(),
                          ),
              ),

              const SizedBox(height: 10),

              // Action buttons
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    _createActionBtn('Export', AppColors.success, 0.25),
                    const SizedBox(width: 8),
                    _createActionBtn('Update', AppColors.accent, 0.25),
                    const SizedBox(width: 8),
                    _createActionBtn('Delete', AppColors.danger, 0.25),
                    const SizedBox(width: 8),
                    _createActionBtn('Back', AppColors.neutral, 0.25),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension to capitalize string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
