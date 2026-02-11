// lib/screens/operations/operations_record_screen_complete.dart
// COMPLETE translation of OperationsRecordScreen from operations.py
// Part 1 of Operations Module - Main Recording Screen (37 methods)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';
import '../../models/operation_config.dart';

class OperationsRecordScreenextends StatefulWidget {
  const OperationsRecordScreen({Key? key}) : super(key: key);

  @override
  State<OperationsRecordScreen> createState() => _OperationsRecordScreenState();
}

class _OperationsRecordScreenState extends State<OperationsRecordScreen> {
  // State variables - equivalent to Python class attributes
  int? _selectedClientId;
  String? _selectedClientName;
  int? _selectedSystemId;
  String? _selectedSystemInfo;
  String? _operationType;
  String? _mode;
  
  // Form fields
  final Map<String, TextEditingController> _fieldControllers = {};
  final Map<String, String> _dropdownValues = {};
  
  // Data lists
  List<Map<String, dynamic>> _clientOptions = [];
  List<Map<String, dynamic>> _systemOptions = [];
  Map<String, dynamic> _lastOperationState = {};
  
  // Date
  final _dateController = TextEditingController();
  
  // Draft storage
  Map<String, dynamic> _draftData = {};
  
  // Loading state
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _loadClients();
  }

  @override
  void dispose() {
    _dateController.dispose();
    for (var controller in _fieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // ==================== LIFECYCLE METHODS ====================
  
  /// Equivalent to on_pre_enter() - load draft when entering screen
  void _onScreenEnter() {
    _loadDraft();
  }

  /// Equivalent to on_pre_leave() - save draft when leaving screen
  void _onScreenLeave() {
    _saveDraft();
  }

  // ==================== DRAFT MANAGEMENT ====================
  
  /// Equivalent to save_draft() - saves current form state
  Future<void> _saveDraft() async {
    if (_selectedClientId == null || _selectedSystemId == null || _operationType == null) {
      return; // Nothing to save
    }

    final draftData = {
      'client_id': _selectedClientId,
      'client_name': _selectedClientName,
      'system_id': _selectedSystemId,
      'system_info': _selectedSystemInfo,
      'operation_type': _operationType,
      'mode': _mode,
      'date': _dateController.text,
      'fields': <String, dynamic>{},
      'dropdowns': _dropdownValues,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Save field values
    _fieldControllers.forEach((key, controller) {
      draftData['fields'][key] = controller.text;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('operations_draft', jsonEncode(draftData));
      debugPrint('Draft saved successfully');
    } catch (e) {
      debugPrint('Error saving draft: $e');
    }
  }

  /// Equivalent to load_draft() - loads saved draft
  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString('operations_draft');
      
      if (draftJson == null) return;
      
      final draftData = jsonDecode(draftJson) as Map<String, dynamic>;
      
      // Check if draft is recent (within 24 hours)
      final timestamp = DateTime.parse(draftData['timestamp']);
      final age = DateTime.now().difference(timestamp);
      
      if (age.inHours > 24) {
        // Draft is too old, discard it
        await _discardDraft();
        return;
      }
      
      // Show draft restore dialog
      _showDraftDialog(draftData, age);
    } catch (e) {
      debugPrint('Error loading draft: $e');
    }
  }

  /// Equivalent to show_draft_dialog() - shows dialog to restore or discard draft
  void _showDraftDialog(Map<String, dynamic> draftData, Duration age) {
    final timeAgo = _formatTimeAgo(age);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            Icon(Icons.restore, color: AppColors.warning),
            const SizedBox(width: 8),
            const Text(
              'Restore Draft?',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Found unsaved operation from $timeAgo',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'Client: ${draftData['client_name'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'System: ${draftData['system_info'] ?? 'Unknown'}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _discardDraft();
            },
            child: Text(
              'Discard',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreDraft(draftData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  /// Equivalent to _format_time_ago() - formats duration as readable string
  String _formatTimeAgo(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hr ago';
    } else {
      return '${duration.inDays} days ago';
    }
  }

  /// Equivalent to restore_draft() - restores draft data to form
  Future<void> _restoreDraft(Map<String, dynamic> draftData) async {
    // Restore client
    setState(() {
      _selectedClientId = draftData['client_id'];
      _selectedClientName = draftData['client_name'];
    });
    
    // Load systems for client
    await _loadSystems(_selectedClientId!);
    
    // Restore system
    setState(() {
      _selectedSystemId = draftData['system_id'];
      _selectedSystemInfo = draftData['system_info'];
    });
    
    // Restore operation type and mode
    setState(() {
      _operationType = draftData['operation_type'];
      _mode = draftData['mode'];
      _dateController.text = draftData['date'];
    });
    
    // Rebuild form with operation fields
    _updateForm();
    
    // Restore field values
    final fields = draftData['fields'] as Map<String, dynamic>;
    fields.forEach((key, value) {
      if (_fieldControllers.containsKey(key)) {
        _fieldControllers[key]!.text = value.toString();
      }
    });
    
    // Restore dropdown values
    setState(() {
      _dropdownValues.addAll(
        Map<String, String>.from(draftData['dropdowns'] as Map),
      );
    });
    
    if (mounted) {
      AppUtils.showSnackbar(context, 'Draft restored successfully');
    }
  }

  /// Equivalent to discard_draft() - discards saved draft
  Future<void> _discardDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('operations_draft');
      if (mounted) {
        AppUtils.showSnackbar(context, 'Draft discarded');
      }
    } catch (e) {
      debugPrint('Error discarding draft: $e');
    }
  }

  // ==================== CLIENT MANAGEMENT ====================
  
  /// Equivalent to load_clients() - loads all clients from database
  Future<void> _loadClients() async {
    try {
      final clients = await DatabaseService.instance.getClients();
      setState(() {
        _clientOptions = clients;
      });
      debugPrint('Loaded ${clients.length} clients');
    } catch (e) {
      debugPrint('Error loading clients: $e');
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error loading clients', isError: true);
      }
    }
  }

  /// Equivalent to show_client_menu() - shows client selection menu
  void _showClientMenu() {
    if (_clientOptions.isEmpty) {
      AppUtils.showSnackbar(context, 'No clients found. Add clients first.');
      return;
    }

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
              'Select Client-Site',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _clientOptions.length,
                itemBuilder: (context, index) {
                  final client = _clientOptions[index];
                  final name = client['name'];
                  final site = client['site_name'] ?? 'No Site';
                  final displayText = '$name ($site)';
                  
                  return ListTile(
                    title: Text(
                      displayText,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _setClient(client['id'], name, site);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Equivalent to set_client() - sets selected client and loads systems
  Future<void> _setClient(int clientId, String name, String site) async {
    setState(() {
      _selectedClientId = clientId;
      _selectedClientName = '$name (${site ?? 'No Site'})';
    });
    
    debugPrint('Client selected: ID=$clientId, Name=$name, Site=$site');
    
    await _loadSystems(clientId);
    _resetDownstreamFromClient();
    
    if (mounted) {
      AppUtils.showSnackbar(context, 'Client selected: $name');
    }
  }

  /// Equivalent to reset_downstream_from_client() - resets system and operation selections
  void _resetDownstreamFromClient() {
    setState(() {
      _selectedSystemId = null;
      _selectedSystemInfo = null;
      _operationType = null;
      _mode = null;
      _fieldControllers.clear();
      _dropdownValues.clear();
      _lastOperationState = {};
    });
    debugPrint('Reset downstream selections from client');
  }

  // ==================== SYSTEM MANAGEMENT ====================
  
  /// Equivalent to load_systems() - loads systems for selected client
  Future<void> _loadSystems(int clientId) async {
    try {
      final systems = await DatabaseService.instance.getSystems(clientId: clientId);
      setState(() {
        _systemOptions = systems;
      });
      debugPrint('Loaded ${systems.length} systems for client $clientId');
      
      if (systems.isEmpty && mounted) {
        AppUtils.showSnackbar(context, 'No systems found for this client');
      }
    } catch (e) {
      debugPrint('Error loading systems: $e');
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error loading systems', isError: true);
      }
    }
  }

  /// Equivalent to show_system_menu() - shows system selection menu
  void _showSystemMenu() {
    if (_selectedClientId == null) {
      AppUtils.showSnackbar(context, 'Please select a client first');
      return;
    }
    
    if (_systemOptions.isEmpty) {
      AppUtils.showSnackbar(context, 'No systems available for this client');
      return;
    }

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
              'Select System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _systemOptions.length,
                itemBuilder: (context, index) {
                  final system = _systemOptions[index];
                  final type = system['type'];
                  final model = system['model'];
                  final serial = system['serial_number'];
                  final displayText = '$type - $model ($serial)';
                  
                  return ListTile(
                    title: Text(
                      displayText,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _setSystem(system['id'], type, model, serial);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Equivalent to set_system() - sets selected system
  Future<void> _setSystem(int systemId, String type, String model, String serial) async {
    if (_selectedClientId == null) {
      AppUtils.showSnackbar(
        context,
        'Session error - client selection lost. Please reselect client.',
        isError: true,
      );
      _resetForm();
      return;
    }
    
    setState(() {
      _selectedSystemId = systemId;
      _selectedSystemInfo = '$type - $model ($serial)';
      _operationType = null;
      _mode = null;
      _fieldControllers.clear();
      _dropdownValues.clear();
    });
    
    debugPrint('System selected: ID=$systemId, Type=$type, Model=$model, Serial=$serial');
    
    await _checkLastOperationState();
    
    if (mounted) {
      AppUtils.showSnackbar(context, 'System selected: $model');
    }
  }

  /// Equivalent to check_last_operation_state() - checks for open operations
  Future<void> _checkLastOperationState() async {
    if (_selectedSystemId == null) return;
    
    try {
      final lastOp = await DatabaseService.instance.getLastOperation(_selectedSystemId!);
      
      if (lastOp != null) {
        setState(() {
          _lastOperationState = {
            'type': lastOp['operation_type'],
            'mode': lastOp['mode'],
            'date': lastOp['date'],
            'data': lastOp['data'],
          };
        });
        
        debugPrint(
          'Last operation: type=${lastOp['operation_type']}, '
          'mode=${lastOp['mode']}, date=${lastOp['date']}',
        );
      } else {
        setState(() {
          _lastOperationState = {};
        });
        debugPrint('No previous operations found for this system');
      }
    } catch (e) {
      debugPrint('Error checking last operation: $e');
      setState(() {
        _lastOperationState = {};
      });
    }
  }

  /// Equivalent to can_record_mode() - validates if mode can be recorded
  Map<String, dynamic> _canRecordMode(String opKey, String mode) {
    final lastOp = _lastOperationState['type'];
    final lastMode = _lastOperationState['mode'];
    
    if (mode == 'stop') {
      if (lastOp != opKey) {
        final opConfig = OperationConfig.getByKey(opKey);
        return {
          'allowed': false,
          'reason': 'No ${opConfig?.name ?? opKey} START found',
        };
      } else if (lastMode != 'start') {
        return {'allowed': false, 'reason': 'Start operation first'};
      }
      return {'allowed': true, 'reason': ''};
    } else if (mode == 'start') {
      if (lastOp == opKey && lastMode == 'start') {
        final lastDate = _lastOperationState['date'] ?? 'unknown date';
        return {
          'allowed': false,
          'reason': 'Stop previous operation (started $lastDate)',
        };
      }
      return {'allowed': true, 'reason': ''};
    }
    
    return {'allowed': true, 'reason': ''};
  }

  // ==================== OPERATION SELECTION ====================
  
  /// Equivalent to show_operation_menu() - shows operation and mode selection
  void _showOperationMenu() {
    if (_selectedSystemId == null) {
      AppUtils.showSnackbar(context, 'Please select a system first');
      return;
    }
    
    if (_selectedClientId == null) {
      AppUtils.showSnackbar(
        context,
        'Session error - please reselect client and system',
        isError: true,
      );
      _resetForm();
      return;
    }

    final lastOp = _lastOperationState['type'];
    final lastMode = _lastOperationState['mode'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Select Operation & Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                if (lastOp != null && lastMode != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Last: ${_lastOperationState['type']} - ${_lastOperationState['mode']}',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: OperationConfig.getAll().length,
                    itemBuilder: (context, index) {
                      final opType = OperationConfig.getAll()[index];
                      
                      return ExpansionTile(
                        leading: Icon(opType.icon, color: opType.color),
                        title: Text(
                          opType.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        children: opType.modes.map((mode) {
                          final validation = _canRecordMode(opType.key, mode);
                          final isAllowed = validation['allowed'] as bool;
                          final reason = validation['reason'] as String;
                          
                          return ListTile(
                            leading: Icon(
                              mode == 'start' ? Icons.play_arrow :
                              mode == 'stop' ? Icons.stop :
                              Icons.note_add,
                              color: isAllowed ? AppColors.success : AppColors.danger,
                            ),
                            title: Text(
                              mode.toUpperCase(),
                              style: TextStyle(
                                color: isAllowed ? Colors.white : Colors.white54,
                              ),
                            ),
                            subtitle: !isAllowed
                                ? Text(
                                    reason,
                                    style: TextStyle(color: AppColors.danger),
                                  )
                                : null,
                            enabled: isAllowed,
                            onTap: isAllowed
                                ? () {
                                    Navigator.pop(context);
                                    _setOperation(opType.key, mode);
                                  }
                                : null,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Equivalent to set_operation() - sets operation type and mode
  void _setOperation(String opType, String mode) {
    setState(() {
      _operationType = opType;
      _mode = mode;
      _fieldControllers.clear();
      _dropdownValues.clear();
    });
    
    debugPrint('Operation set: type=$opType, mode=$mode');
    _updateForm();
    
    final opConfig = OperationConfig.getByKey(opType);
    if (mounted) {
      AppUtils.showSnackbar(context, 'Operation set: ${opConfig?.name ?? opType} - ${mode.toUpperCase()}');
    }
  }

  /// Equivalent to update_form() - rebuilds form with operation fields
  void _updateForm() {
    if (_operationType == null || _mode == null) return;
    
    final fields = OperationConfig.getFields(_operationType!, _mode!);
    if (fields == null) return;
    
    // Create controllers for new fields
    setState(() {
      _fieldControllers.clear();
      _dropdownValues.clear();
      
      for (final field in fields) {
        if (field.type != FieldType.dropdown) {
          _fieldControllers[field.id] = TextEditingController();
        }
      }
    });
    
    debugPrint('Form updated with ${fields.length} fields');
  }

  // ==================== SAVE & VALIDATION ====================
  
  /// Equivalent to save_record() - validates and saves operation
  Future<void> _saveRecord() async {
    // Validation
    if (_selectedClientId == null || _selectedSystemId == null) {
      AppUtils.showSnackbar(context, 'Please select client and system', isError: true);
      return;
    }
    
    if (_operationType == null || _mode == null) {
      AppUtils.showSnackbar(context, 'Please select operation type', isError: true);
      return;
    }
    
    // Collect field data
    final data = <String, dynamic>{};
    
    _fieldControllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        data[key] = controller.text;
      }
    });
    
    _dropdownValues.forEach((key, value) {
      data[key] = value;
    });
    
    // Validate required fields
    final fields = OperationConfig.getFields(_operationType!, _mode!);
    if (fields != null) {
      for (final field in fields) {
        if (!data.containsKey(field.id) || data[field.id].toString().isEmpty) {
          AppUtils.showSnackbar(
            context,
            '${field.label} is required',
            isError: true,
          );
          return;
        }
      }
    }
    
    // Parse date
    DateTime dateObj;
    try {
      dateObj = DateFormat('dd-MM-yyyy').parse(_dateController.text);
    } catch (e) {
      AppUtils.showSnackbar(context, 'Invalid date format', isError: true);
      return;
    }
    
    // Show confirmation dialog
    _showConfirmationDialog(data, dateObj);
  }

  /// Equivalent to show_confirmation_dialog() - shows save confirmation
  void _showConfirmationDialog(Map<String, dynamic> data, DateTime dateObj) {
    final opConfig = OperationConfig.getByKey(_operationType!);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Confirm Save',
          style: TextStyle(color: AppColors.accent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operation: ${opConfig?.name ?? _operationType}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Mode: ${_mode?.toUpperCase()}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Date: ${_dateController.text}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSave(data, dateObj);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  /// Equivalent to perform_save() - performs the actual save
  Future<void> _performSave(Map<String, dynamic> data, DateTime dateObj) async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      final operationData = {
        'system_id': _selectedSystemId,
        'client_id': _selectedClientId,
        'operation_type': _operationType,
        'mode': _mode,
        'date': DateFormat('yyyy-MM-dd').format(dateObj),
        'data': jsonEncode(data),
      };
      
      await DatabaseService.instance.insertOperation(operationData);
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'Operation saved successfully');
        _discardDraft();
        _resetForm();
      }
    } catch (e) {
      debugPrint('Error saving operation: $e');
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error saving: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Equivalent to reset_form() - resets entire form
  void _resetForm() {
    setState(() {
      _selectedClientId = null;
      _selectedClientName = null;
      _selectedSystemId = null;
      _selectedSystemInfo = null;
      _operationType = null;
      _mode = null;
      _fieldControllers.clear();
      _dropdownValues.clear();
      _lastOperationState = {};
      _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    });
    
    _loadClients();
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    final fields = _operationType != null && _mode != null
        ? OperationConfig.getFields(_operationType!, _mode!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Daily Operations Record',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Selection section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Client-Site
                FormRow(
                  labelText: 'Client-Site',
                  fieldWidget: GestureDetector(
                    onTap: _showClientMenu,
                    child: AbsorbPointer(
                      child: RoundedTextField(
                        hint: 'Select Client-Site',
                        controller: TextEditingController(
                          text: _selectedClientName ?? '',
                        ),
                        readOnly: true,
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // System
                FormRow(
                  labelText: 'System',
                  fieldWidget: GestureDetector(
                    onTap: _showSystemMenu,
                    child: AbsorbPointer(
                      child: RoundedTextField(
                        hint: 'Select System',
                        controller: TextEditingController(
                          text: _selectedSystemInfo ?? '',
                        ),
                        readOnly: true,
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Operation
                FormRow(
                  labelText: 'Operation',
                  fieldWidget: GestureDetector(
                    onTap: _showOperationMenu,
                    child: AbsorbPointer(
                      child: RoundedTextField(
                        hint: 'Select Operation & Mode',
                        controller: TextEditingController(
                          text: _operationType != null && _mode != null
                              ? '${OperationConfig.getByKey(_operationType!)?.name} - ${_mode?.toUpperCase()}'
                              : '',
                        ),
                        readOnly: true,
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Date
                DateTimeRow(
                  labelText: 'Date',
                  controller: _dateController,
                  isDate: true,
                ),
              ],
            ),
          ),
          
          // Dynamic form fields
          Expanded(
            child: fields != null && fields.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      final field = fields[index];
                      
                      if (field.type == FieldType.dropdown) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: FormRow(
                            labelText: field.label,
                            fieldWidget: GestureDetector(
                              onTap: () => _showDropdownPicker(
                                field.id,
                                field.label,
                                field.dropdownOptions ?? [],
                              ),
                              child: AbsorbPointer(
                                child: RoundedTextField(
                                  hint: field.label,
                                  controller: TextEditingController(
                                    text: _dropdownValues[field.id] ?? '',
                                  ),
                                  readOnly: true,
                                  suffixIcon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (field.type == FieldType.time) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DateTimeRow(
                            labelText: field.label,
                            controller: _fieldControllers[field.id]!,
                            isDate: false,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: FormRow(
                            labelText: field.label,
                            fieldWidget: RoundedTextField(
                              hint: field.label,
                              controller: _fieldControllers[field.id],
                              keyboardType: field.type == FieldType.floatNumber
                                  ? const TextInputType.numberWithOptions(decimal: true)
                                  : TextInputType.text,
                            ),
                          ),
                        );
                      }
                    },
                  )
                : Center(
                    child: Text(
                      'Select operation to begin',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
          
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutral,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveRecord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Record',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/operations_reports');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3399CC),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reports'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to show dropdown picker
  void _showDropdownPicker(String fieldId, String label, List<String> options) {
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
              'Select $label',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              return ListTile(
                title: Text(
                  option,
                  style: const TextStyle(color: Colors.white),
                ),
                selected: _dropdownValues[fieldId] == option,
                selectedTileColor: AppColors.accent.withOpacity(0.2),
                onTap: () {
                  setState(() {
                    _dropdownValues[fieldId] = option;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
