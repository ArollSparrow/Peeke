// lib/screens/registration/update_system_screen_complete.dart
// COMPLETE translation of UpdateRegistrationSystemScreen from registration.py
// Part 3/5: Update System with load and reset functionality

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';

class UpdateSystemScreenComplete extends StatefulWidget {
  final int? systemId;

  const UpdateSystemScreenComplete({
    Key? key,
    this.systemId,
  }) : super(key: key);

  @override
  State<UpdateSystemScreenComplete> createState() => _UpdateSystemScreenCompleteState();
}

class _UpdateSystemScreenCompleteState extends State<UpdateSystemScreenComplete> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _serialNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _capacityValueController = TextEditingController();
  final _installationDateController = TextEditingController();
  final _registrationDateController = TextEditingController();
  final _otherTypeController = TextEditingController();
  
  // State
  int? _systemId;
  String _selectedType = '';
  String _selectedUnit = '';
  Map<String, dynamic> _originalData = {};
  String _clientName = '';
  
  // Options
  final List<String> _systemTypes = ['Generator', 'PV Inverter', 'Pump Inverter', 'Other'];
  final List<String> _capacityUnits = ['kW', 'kVA'];

  @override
  void initState() {
    super.initState();
    _systemId = widget.systemId;
    if (_systemId != null) {
      _loadSystem(_systemId!);
    }
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _modelController.dispose();
    _barcodeController.dispose();
    _capacityValueController.dispose();
    _installationDateController.dispose();
    _registrationDateController.dispose();
    _otherTypeController.dispose();
    super.dispose();
  }

  // ==================== LOAD SYSTEM ====================
  
  /// Equivalent to load_system() - loads existing system data
  Future<void> _loadSystem(int systemId) async {
    try {
      final data = await DatabaseService.instance.getSystemById(systemId);
      
      if (data == null) {
        if (mounted) {
          AppUtils.showSnackbar(context, 'System not found', isError: true);
        }
        return;
      }

      // Store original data for reset
      _originalData = {
        'type': data['type'],
        'serial': data['serial_number'],
        'model': data['model'],
        'capacity': data['capacity'],
        'unit': data['capacity_unit'],
        'barcode': data['barcode'],
        'install': data['installation_date'],
        'reg': data['registration_date'],
        'client': data['client_name'],
      };

      // Populate form fields
      setState(() {
        _clientName = data['client_name'] ?? '';
        
        final String type = data['type'] ?? '';
        if (_systemTypes.contains(type)) {
          _selectedType = type;
          _otherTypeController.clear();
        } else {
          _selectedType = 'Other';
          _otherTypeController.text = type;
        }
        
        _serialNumberController.text = data['serial_number'] ?? '';
        _modelController.text = data['model'] ?? '';
        _capacityValueController.text = data['capacity']?.toString() ?? '';
        _selectedUnit = data['capacity_unit'] ?? '';
        _barcodeController.text = data['barcode'] ?? '';
        _installationDateController.text = data['installation_date'] ?? '';
        _registrationDateController.text = data['registration_date'] ?? '';
      });
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error loading system: $e', isError: true);
      }
    }
  }

  // ==================== RESET FORM ====================
  
  /// Equivalent to reset_form() - resets form to original values
  void _resetForm() {
    if (_originalData.isEmpty) {
      AppUtils.showSnackbar(context, 'No original data to reset');
      return;
    }

    setState(() {
      final String type = _originalData['type'] ?? '';
      if (_systemTypes.contains(type)) {
        _selectedType = type;
        _otherTypeController.clear();
      } else {
        _selectedType = 'Other';
        _otherTypeController.text = type;
      }
      
      _serialNumberController.text = _originalData['serial'] ?? '';
      _modelController.text = _originalData['model'] ?? '';
      _capacityValueController.text = _originalData['capacity']?.toString() ?? '';
      _selectedUnit = _originalData['unit'] ?? '';
      _barcodeController.text = _originalData['barcode'] ?? '';
      _installationDateController.text = _originalData['install'] ?? '';
      _registrationDateController.text = _originalData['reg'] ?? '';
    });

    AppUtils.showSnackbar(context, 'Form reset to original values');
  }

  // ==================== VALIDATION & UPDATE ====================
  
  /// Validates form fields
  Map<String, dynamic> _validateForm() {
    final List<String> errors = [];
    
    String systemType = _selectedType;
    if (_selectedType == 'Other') {
      systemType = _otherTypeController.text.trim();
      if (systemType.isEmpty) {
        errors.add('Specify type for "Other"');
      }
    } else if (_selectedType.isEmpty) {
      errors.add('System Type required');
    }
    
    if (_serialNumberController.text.trim().isEmpty) {
      errors.add('Serial Number required');
    }
    if (_modelController.text.trim().isEmpty) {
      errors.add('Model required');
    }
    if (_capacityValueController.text.trim().isEmpty) {
      errors.add('Capacity required');
    }
    if (_selectedUnit.isEmpty) {
      errors.add('Capacity Unit required');
    }
    
    try {
      double.parse(_capacityValueController.text.trim());
    } catch (e) {
      errors.add('Capacity must be numeric');
    }
    
    for (final controller in [_installationDateController, _registrationDateController]) {
      try {
        DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (e) {
        errors.add('Invalid date format (use DD-MM-YYYY)');
        break;
      }
    }
    
    return {
      'type': systemType,
      'errors': errors,
    };
  }

  /// Equivalent to update_system() - updates system in database
  Future<void> _updateSystem() async {
    if (_systemId == null) {
      AppUtils.showSnackbar(context, 'No system loaded', isError: true);
      return;
    }

    final validation = _validateForm();
    final List<String> errors = validation['errors'];
    
    if (errors.isNotEmpty) {
      AppUtils.showSnackbar(context, errors.join('\n'), isError: true);
      return;
    }
    
    final String systemType = validation['type'];
    
    final updateData = {
      'type': systemType,
      'serial_number': _serialNumberController.text.trim(),
      'model': _modelController.text.trim(),
      'capacity': double.parse(_capacityValueController.text.trim()),
      'capacity_unit': _selectedUnit,
      'barcode': _barcodeController.text.trim().isNotEmpty 
          ? _barcodeController.text.trim() 
          : null,
      'installation_date': _installationDateController.text,
      'registration_date': _registrationDateController.text,
    };
    
    try {
      await DatabaseService.instance.updateSystem(_systemId!, updateData);
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'System updated successfully');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('UNIQUE')) {
          AppUtils.showSnackbar(context, 'Serial number already exists', isError: true);
        } else {
          AppUtils.showSnackbar(context, 'Update failed: $e', isError: true);
        }
      }
    }
  }

  // ==================== DROPDOWN METHODS ====================
  
  void _showTypePicker() {
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
              'Select System Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            ..._systemTypes.map((type) {
              return ListTile(
                title: Text(type, style: const TextStyle(color: Colors.white)),
                selected: _selectedType == type,
                selectedTileColor: AppColors.accent.withOpacity(0.2),
                onTap: () {
                  setState(() => _selectedType = type);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showUnitPicker() {
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
              'Select Unit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            ..._capacityUnits.map((unit) {
              return ListTile(
                title: Text(unit, style: const TextStyle(color: Colors.white)),
                selected: _selectedUnit == unit,
                selectedTileColor: AppColors.accent.withOpacity(0.2),
                onTap: () {
                  setState(() => _selectedUnit = unit);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    final subtitle = _serialNumberController.text.isNotEmpty && _clientName.isNotEmpty
        ? 'Serial: ${_serialNumberController.text} | Client: $_clientName'
        : 'System: Not loaded';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          HeaderBox(
            title: 'Update System',
            subtitle: subtitle,
            includeClock: false,
          ),
          
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.formPadding),
                children: [
                  Text('System Type', style: TextStyle(color: AppColors.accent, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownTextField(
                    hint: 'Select Type',
                    controller: TextEditingController(text: _selectedType),
                    onTap: _showTypePicker,
                    required: true,
                  ),
                  
                  if (_selectedType == 'Other') ...[
                    const SizedBox(height: 16),
                    RoundedTextField(
                      label: 'Specify Type',
                      controller: _otherTypeController,
                      required: true,
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  RoundedTextField(
                    label: 'Serial Number',
                    controller: _serialNumberController,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  RoundedTextField(
                    label: 'Model',
                    controller: _modelController,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  RoundedTextField(
                    label: 'Barcode',
                    controller: _barcodeController,
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Capacity', style: TextStyle(color: AppColors.accent, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: RoundedTextField(
                          hint: 'Value',
                          controller: _capacityValueController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: DropdownTextField(
                          hint: 'Unit',
                          controller: TextEditingController(text: _selectedUnit),
                          onTap: _showUnitPicker,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  DateTimeRow(
                    labelText: 'Installation Date',
                    controller: _installationDateController,
                    isDate: true,
                  ),
                  const SizedBox(height: 16),
                  DateTimeRow(
                    labelText: 'Registration Date',
                    controller: _registrationDateController,
                    isDate: true,
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
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
                  onPressed: _resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('RESET'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _updateSystem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('UPDATE'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
