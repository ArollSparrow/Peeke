// lib/screens/registration/system_registration_screen.dart
// COMPLETE translation of SystemRegistrationScreen from registration.py
// Part 2/5: System Registration with all fields and validations
// FIX: Replaced broken DropdownTextField (inline controller re-created on every
//      build) with Flutter's native DropdownButtonFormField, which owns its own
//      state and updates correctly on selection.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';

class SystemRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic>? clientData;

  const SystemRegistrationScreen({
    Key? key,
    this.clientData,
  }) : super(key: key);

  @override
  State<SystemRegistrationScreen> createState() =>
      _SystemRegistrationScreenState();
}

class _SystemRegistrationScreenState extends State<SystemRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all system fields
  final _serialNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _capacityValueController = TextEditingController();
  final _installationDateController = TextEditingController();
  final _registrationDateController = TextEditingController();
  final _otherTypeController = TextEditingController();

  // ── Dropdown selections ──────────────────────────────────────
  // These are the single source of truth for both dropdowns.
  // null = nothing selected yet (shows hint text).
  String? _selectedType;
  String? _selectedUnit;

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

  // ─────────────────────────────────────────────────────────────

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

  // ==================== INITIALIZATION ====================

  void _initializeDefaults() {
    final today = AppUtils.getTodayFormatted();
    _installationDateController.text = today;
    _registrationDateController.text = today;
  }

  // ==================== DATE PICKER ====================

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) =>
          Theme(data: ThemeData.dark(), child: child!),
    );

    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  // ==================== VALIDATION ====================

  Map<String, dynamic> _validateForm() {
    final List<String> errors = [];

    // System type
    String systemType = _selectedType ?? '';
    if (_selectedType == 'Other') {
      systemType = _otherTypeController.text.trim();
      if (systemType.isEmpty) errors.add('Specify type for "Other"');
    } else if (_selectedType == null || _selectedType!.isEmpty) {
      errors.add('System Type required');
    }

    // Required text fields
    if (_serialNumberController.text.trim().isEmpty) {
      errors.add('Serial Number required');
    }
    if (_modelController.text.trim().isEmpty) {
      errors.add('Model required');
    }
    if (_capacityValueController.text.trim().isEmpty) {
      errors.add('Capacity required');
    }
    if (_selectedUnit == null || _selectedUnit!.isEmpty) {
      errors.add('Capacity Unit required');
    }

    // Numeric capacity
    if (_capacityValueController.text.trim().isNotEmpty) {
      if (double.tryParse(_capacityValueController.text.trim()) == null) {
        errors.add('Capacity must be numeric');
      }
    }

    // Date formats
    for (final controller in [
      _installationDateController,
      _registrationDateController,
    ]) {
      try {
        DateFormat('dd-MM-yyyy').parseStrict(controller.text);
      } catch (_) {
        errors.add('Invalid date format (use DD-MM-YYYY)');
        break;
      }
    }

    return {'type': systemType, 'errors': errors};
  }

  // ==================== SAVE ====================

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
      AppUtils.showSnackbar(context, errors.join('\n'), isError: true);
      return;
    }

    final systemData = {
      'client_id': _clientData!['id'],
      'type': validation['type'],
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
        final msg = e.toString().contains('UNIQUE')
            ? 'Serial number already exists'
            : 'Save failed: $e';
        AppUtils.showSnackbar(context, msg, isError: true);
      }
    }
  }

  // ==================== CLEAR ====================

  void _clearForm() {
    setState(() {
      _selectedType = null;
      _selectedUnit = null;
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

  // ==================== SHARED DROPDOWN DECORATION ====================

  /// Dark-themed InputDecoration used by both DropdownButtonFormFields.
  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.danger),
      ),
    );
  }

  // ==================== BUILD ====================

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
          // Header
          HeaderBox(
            title: 'System Registration',
            subtitle: subtitle,
            includeClock: true,
          ),

          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.formPadding),
                children: [
                  // ── System Type ──────────────────────────────────
                  Text(
                    'System Type *',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // FIX: DropdownButtonFormField owns its own state.
                  // _selectedType is null until the user picks an item,
                  // and is set via onChanged → setState, so the widget
                  // always reflects the correct value.
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: _dropdownDecoration('Select Type'),
                    dropdownColor: AppColors.cardBackground,
                    iconEnabledColor: AppColors.accent,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    items: _systemTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value),
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'System Type required'
                            : null,
                  ),

                  // "Other" custom type field
                  if (_selectedType == 'Other') ...[
                    const SizedBox(height: 16),
                    RoundedTextField(
                      label: 'Specify Type',
                      hint: 'Enter custom type',
                      controller: _otherTypeController,
                      required: true,
                      validator: (value) =>
                          AppUtils.validateRequired(value, 'Type'),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Serial Number ────────────────────────────────
                  RoundedTextField(
                    label: 'Serial Number',
                    hint: 'Enter serial number',
                    controller: _serialNumberController,
                    required: true,
                    validator: (value) =>
                        AppUtils.validateRequired(value, 'Serial Number'),
                  ),
                  const SizedBox(height: 16),

                  // ── Model ────────────────────────────────────────
                  RoundedTextField(
                    label: 'Model',
                    hint: 'Enter model',
                    controller: _modelController,
                    required: true,
                    validator: (value) =>
                        AppUtils.validateRequired(value, 'Model'),
                  ),
                  const SizedBox(height: 16),

                  // ── Barcode ──────────────────────────────────────
                  RoundedTextField(
                    label: 'Barcode',
                    hint: 'Enter barcode (optional)',
                    controller: _barcodeController,
                  ),
                  const SizedBox(height: 16),

                  // ── Capacity + Unit ──────────────────────────────
                  Text(
                    'Capacity *',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Numeric value
                      Expanded(
                        flex: 6,
                        child: RoundedTextField(
                          hint: 'Value',
                          controller: _capacityValueController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          required: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Capacity required';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Must be numeric';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // FIX: Same pattern — DropdownButtonFormField for unit.
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: _dropdownDecoration('Unit'),
                          dropdownColor: AppColors.cardBackground,
                          iconEnabledColor: AppColors.accent,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          items: _capacityUnits
                              .map((unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedUnit = value),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Unit required'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Installation Date ────────────────────────────
                  DateTimeRow(
                    labelText: 'Installation Date',
                    controller: _installationDateController,
                    isDate: true,
                  ),
                  const SizedBox(height: 16),

                  // ── Registration Date ────────────────────────────
                  DateTimeRow(
                    labelText: 'Registration Date',
                    controller: _registrationDateController,
                    isDate: true,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom buttons ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _clearForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  child: const Text('CLEAR'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveSystem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
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
