// lib/screens/registration/system_registration_screen_complete.dart
// COMPLETE translation of SystemRegistrationScreen from registration.py
// Part 2/5: System Registration with all fields and validations

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';

class SystemRegistrationScreenComplete extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const SystemRegistrationScreenComplete({
    Key? key,
    this.clientData,
  }) : super(key: key);

  @override
  State<SystemRegistrationScreenComplete> createState() => _SystemRegistrationScreenCompleteState();
}

class _SystemRegistrationScreenCompleteState extends State<SystemRegistrationScreenComplete> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all system fields
  final _serialNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _capacityValueController = TextEditingController();
  final _installationDateController = TextEditingController();
  final _registrationDateController = TextEditingController();
  
  // Dropdown selections
  String _selectedType = '';
  String _selectedUnit = '';
  final _otherTypeController = TextEditingController();
  
  // Client data from previous screen
  Map<String, dynamic>? _clientData;
  
  // System type options
  final List<String> _systemTypes = [
    'Generator',
    'PV Inverter',
    'Pump Inverter',
    'Other',
  ];
  
  // Capacity unit options
  final List<String> _capacityUnits = ['kW', 'kVA'];

  @override
  void initState() {
    super.initState();
    _clientData = widget.clientData;
    _initializeDefaults();
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

  // ==================== INITIALIZATION METHODS ====================
  
  /// Equivalent to on_pre_enter() - initializes form with today's date
  void _initializeDefaults() {
    final today = AppUtils.getTodayFormatted();
    _installationDateController.text = today;
    _registrationDateController.text = today;
  }

  // ==================== DROPDOWN METHODS ====================
  
  /// Equivalent to select_type() - handles system type selection
  void _selectType(String type) {
    setState(() {
      _selectedType = type;
    });
  }

  /// Equivalent to select_unit() - handles capacity unit selection
  void _selectUnit(String unit) {
    setState(() {
      _selectedUnit = unit;
    });
  }

  /// Shows system type picker
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            ..._systemTypes.map((type) {
              return ListTile(
                title: Text(
                  type,
                  style: const TextStyle(color: Colors.white),
                ),
                selected: _selectedType == type,
                selectedTileColor: AppColors.accent.withOpacity(0.2),
                onTap: () {
                  _selectType(type);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// Shows capacity unit picker
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            ..._capacityUnits.map((unit) {
              return ListTile(
                title: Text(
                  unit,
                  style: const TextStyle(color: Colors.white),
                ),
                selected: _selectedUnit == unit,
                selectedTileColor: AppColors.accent.withOpacity(0.2),
                onTap: () {
                  _selectUnit(unit);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ==================== DATE PICKER METHODS ====================
  
  /// Equivalent to open_date_picker() - opens date picker for installation/registration dates
  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  // ==================== VALIDATION METHODS ====================
  
  /// Equivalent to validate_form() - validates all system form fields
  Map<String, dynamic> _validateForm() {
    final List<String> errors = [];
    
    // Validate system type
    String systemType = _selectedType;
    if (_selectedType == 'Other') {
      systemType = _otherTypeController.text.trim();
      if (systemType.isEmpty) {
        errors.add('Specify type for "Other"');
      }
    } else if (_selectedType.isEmpty) {
      errors.add('System Type required');
    }
    
    // Validate required fields
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
    
    // Validate capacity value is numeric
    try {
      double.parse(_capacityValueController.text.trim());
    } catch (e) {
      errors.add('Capacity must be numeric');
    }
    
    // Validate date formats
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

  // ==================== SAVE METHODS ====================
  
  /// Equivalent to save_system() - saves new system to database
  Future<void> _saveSystem() async {
    if (_clientData == null || _clientData!['id'] == null) {
      AppUtils.showSnackbar(
        context,
        'No client selected. Register/select client first.',
        isError: true,
      );
      return;
    }
    
    final validation = _validateForm();
    final List<String> errors = validation['errors'];
    
    if (errors.isNotEmpty) {
      AppUtils.showSnackbar(
        context,
        errors.join('\n'),
        isError: true,
      );
      return;
    }
    
    final String systemType = validation['type'];
    
    final systemData = {
      'client_id': _clientData!['id'],
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
      await DatabaseService.instance.insertSystem(systemData);
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'System saved successfully');
        _clearForm();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('UNIQUE')) {
          AppUtils.showSnackbar(
            context,
            'Serial number already exists',
            isError: true,
          );
        } else {
          AppUtils.showSnackbar(
            context,
            'Save failed: $e',
            isError: true,
          );
        }
      }
    }
  }

  // ==================== FORM MANAGEMENT METHODS ====================
  
  /// Equivalent to clear_form() - resets all form fields to defaults
  void _clearForm() {
    setState(() {
      _selectedType = '';
      _selectedUnit = '';
      _serialNumberController.clear();
      _modelController.clear();
      _barcodeController.clear();
      _capacityValueController.clear();
      _otherTypeController.clear();
      
      final today = AppUtils.getTodayFormatted();
      _installationDateController.text = today;
      _registrationDateController.text = today;
    });
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    final clientName = _clientData?['name'] ?? 'Not selected';
    final siteName = _clientData?['site_name'] ?? '';
    final subtitle = siteName.isNotEmpty 
        ? 'Client: $clientName | Site: $siteName'
        : 'Client: $clientName';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Header with client info
          HeaderBox(
            title: 'System Registration',
            subtitle: subtitle,
            includeClock: true,
          ),
          
          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.formPadding),
                children: [
                  // System Type dropdown
                  Text(
                    'System Type',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownTextField(
                    hint: 'Select Type',
                    controller: TextEditingController(text: _selectedType),
                    onTap: _showTypePicker,
                    required: true,
                  ),
                  
                  // Other type field (shown only if Other is selected)
                  if (_selectedType == 'Other') ...[
                    const SizedBox(height: 16),
                    RoundedTextField(
                      label: 'Specify Type',
                      hint: 'Enter custom type',
                      controller: _otherTypeController,
                      required: true,
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Serial Number
                  RoundedTextField(
                    label: 'Serial Number',
                    hint: 'Enter serial number',
                    controller: _serialNumberController,
                    required: true,
                    validator: (value) => AppUtils.validateRequired(value, 'Serial Number'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Model
                  RoundedTextField(
                    label: 'Model',
                    hint: 'Enter model',
                    controller: _modelController,
                    required: true,
                    validator: (value) => AppUtils.validateRequired(value, 'Model'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Barcode
                  RoundedTextField(
                    label: 'Barcode',
                    hint: 'Enter barcode (optional)',
                    controller: _barcodeController,
                  ),
                  const SizedBox(height: 16),
                  
                  // Capacity
                  Text(
                    'Capacity',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: RoundedTextField(
                          hint: 'Value',
                          controller: _capacityValueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  
                  // Installation Date
                  DateTimeRow(
                    labelText: 'Installation Date',
                    controller: _installationDateController,
                    isDate: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Registration Date
                  DateTimeRow(
                    labelText: 'Registration Date',
                    controller: _registrationDateController,
                    isDate: true,
                  ),
                ],
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
                // Back button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
                const Spacer(),
                
                // Clear button
                ElevatedButton(
                  onPressed: _clearForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('CLEAR'),
                ),
                const SizedBox(width: 8),
                
                // Save button
                ElevatedButton(
                  onPressed: _saveSystem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('SAVE SYSTEM'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
