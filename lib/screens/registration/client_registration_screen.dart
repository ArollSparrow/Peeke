// lib/screens/registration/client_registration_screen_complete.dart
// COMPLETE translation of ClientRegistrationScreen from registration.py
// Includes ALL methods and functionality

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';

class ClientRegistrationScreenextends StatefulWidget {
  const ClientRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<ClientRegistrationScreen> createState() => _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers - equivalent to self.inputs
  final _clientNameController = TextEditingController();
  final _siteNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _coordinatesController = TextEditingController();
  
  // State variables - equivalent to Python class attributes
  bool _gpsRunning = false;
  Map<String, dynamic>? _currentClientData;
  bool _isExistingClient = false;
  String _gpsStatus = 'GPS: Ready';
  List<Map<String, dynamic>> _existingClients = [];
  Timer? _searchDebounce;
  
  // Button states
  bool _saveButtonEnabled = true;
  bool _saveAsNewButtonEnabled = false;
  bool _proceedButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadExistingClients();
    _checkGpsPermission();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _siteNameController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _coordinatesController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ==================== SETUP METHODS ====================
  
  /// Equivalent to setup_client_fields() - loads existing clients from database
  Future<void> _loadExistingClients() async {
    try {
      final clients = await DatabaseService.instance.getClients();
      setState(() {
        _existingClients = clients;
      });
    } catch (e) {
      debugPrint('Error loading clients: $e');
    }
  }

  /// Equivalent to configure_gps() - checks GPS permissions
  Future<void> _checkGpsPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      setState(() {
        _gpsStatus = 'GPS: Ready';
      });
    } catch (e) {
      setState(() {
        _gpsStatus = 'GPS: Unavailable';
      });
    }
  }

  // ==================== GPS METHODS ====================
  
  /// Equivalent to toggle_gps() - starts/stops GPS location acquisition
  Future<void> _toggleGps() async {
    if (_gpsRunning) {
      _cleanupGps();
      setState(() {
        _gpsStatus = 'GPS: Stopped';
      });
      return;
    }

    setState(() {
      _gpsRunning = true;
      _gpsStatus = 'GPS: Getting location...';
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 30));
      
      if (mounted) {
        setState(() {
          _coordinatesController.text = '${position.latitude.toStringAsFixed(6)},${position.longitude.toStringAsFixed(6)}';
          _gpsStatus = 'GPS: Location acquired';
          _gpsRunning = false;
        });
        
        AppUtils.showSnackbar(context, 'Location acquired successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _gpsStatus = 'GPS: Error - $e';
          _gpsRunning = false;
        });
        
        AppUtils.showSnackbar(context, 'Failed to get location: $e', isError: true);
      }
    }
  }

  /// Equivalent to cleanup_gps() - stops GPS
  void _cleanupGps() {
    setState(() {
      _gpsRunning = false;
    });
  }

  /// Equivalent to _validate_coords() - validates coordinate format
  bool _validateCoords(String text) {
    try {
      final parts = text.split(',');
      if (parts.length != 2) return false;
      
      final lat = double.parse(parts[0].trim());
      final lon = double.parse(parts[1].trim());
      
      return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
    } catch (e) {
      return false;
    }
  }

  // ==================== CLIENT SEARCH METHODS ====================
  
  /// Equivalent to on_client_name_change() - handles client name text changes with debouncing
  void _onClientNameChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _performClientSearch(value);
    });
  }

  /// Equivalent to _perform_client_search() - searches for existing clients
  void _performClientSearch(String text) {
    text = text.trim();
    
    if (text.isEmpty) {
      setState(() {
        _currentClientData = null;
        _isExistingClient = false;
        _setFieldsForNew();
        _updateButtons();
      });
      return;
    }

    // Search for matching clients
    final matches = _existingClients.where((client) {
      final name = (client['name'] ?? '').toString().toLowerCase();
      return name.contains(text.toLowerCase());
    }).toList();

    // If exact match found, load it
    final exactMatch = matches.firstWhere(
      (client) => (client['name'] ?? '').toString().toLowerCase() == text.toLowerCase(),
      orElse: () => {},
    );

    if (exactMatch.isNotEmpty) {
      _fillFromClient(exactMatch);
    }
  }

  /// Equivalent to open_client_menu() - shows client selection menu
  void _showClientMenu() {
    if (_existingClients.isEmpty) {
      AppUtils.showSnackbar(context, 'No existing clients found');
      return;
    }

    final searchText = _clientNameController.text.trim().toLowerCase();
    final filteredClients = searchText.isEmpty
        ? _existingClients
        : _existingClients.where((client) {
            final name = (client['name'] ?? '').toString().toLowerCase();
            return name.contains(searchText);
          }).toList();

    if (filteredClients.isEmpty) {
      AppUtils.showSnackbar(context, 'No matching clients found');
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
              'Select Client',
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
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  final siteName = client['site_name'] ?? '';
                  final location = client['location'] ?? '';
                  final subtitle = siteName.isNotEmpty && location.isNotEmpty
                      ? '$siteName — $location'
                      : siteName.isNotEmpty ? siteName : location;
                  
                  return ListTile(
                    title: Text(
                      client['name'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: subtitle.isNotEmpty
                        ? Text(
                            subtitle,
                            style: const TextStyle(color: Colors.white70),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _clientNameController.text = client['name'];
                      _fillFromClient(client);
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

  /// Equivalent to fill_from_client() - fills form with existing client data
  void _fillFromClient(Map<String, dynamic> client) {
    setState(() {
      _currentClientData = client;
      _isExistingClient = true;
      
      _clientNameController.text = client['name'] ?? '';
      _siteNameController.text = client['site_name'] ?? '';
      _locationController.text = client['location'] ?? '';
      _contactController.text = client['contact'] ?? '';
      _coordinatesController.text = client['location_coords'] ?? '';
      
      _setFieldsForExisting();
      _updateButtons();
    });

    AppUtils.showSnackbar(
      context,
      'Existing client selected — update, save as new record, or proceed',
    );
  }

  // ==================== FIELD STATE METHODS ====================
  
  /// Equivalent to set_fields_for_new() - enables all fields for new entry
  void _setFieldsForNew() {
    setState(() {
      _saveButtonEnabled = true;
      _saveAsNewButtonEnabled = false;
      _proceedButtonEnabled = false;
    });
  }

  /// Equivalent to set_fields_for_existing() - configures fields for existing client
  void _setFieldsForExisting() {
    setState(() {
      _saveButtonEnabled = true;
      _saveAsNewButtonEnabled = true;
      _proceedButtonEnabled = true;
    });
  }

  /// Equivalent to update_buttons() - updates button text and colors
  void _updateButtons() {
    // Button states are managed through _saveButtonEnabled, etc.
    // Text changes happen in the button builders
  }

  // ==================== SAVE METHODS ====================
  
  /// Equivalent to save_or_update() - saves new client or updates existing
  Future<void> _saveOrUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final clientName = _clientNameController.text.trim();
    final siteName = _siteNameController.text.trim();
    final location = _locationController.text.trim();
    final contact = _contactController.text.trim();
    final coords = _coordinatesController.text.trim();

    // Validate required fields
    final List<String> missing = [];
    if (clientName.isEmpty) missing.add('Client Name');
    if (siteName.isEmpty) missing.add('Site Name');
    if (location.isEmpty) missing.add('Location');
    
    if (missing.isNotEmpty) {
      AppUtils.showSnackbar(
        context,
        'Required: ${missing.join(', ')}',
        isError: true,
      );
      return;
    }

    // Validate coordinates if provided
    if (coords.isNotEmpty && !_validateCoords(coords)) {
      AppUtils.showSnackbar(
        context,
        'Invalid coordinates format (use: lat,lon)',
        isError: true,
      );
      return;
    }

    final clientData = {
      'name': clientName,
      'site_name': siteName,
      'location': location,
      'contact': contact,
      'location_coords': coords.isNotEmpty ? coords : null,
    };

    try {
      if (_isExistingClient && _currentClientData != null) {
        // UPDATE existing client
        final clientId = _currentClientData!['id'];
        await DatabaseService.instance.updateClient(clientId, clientData);
        
        setState(() {
          _currentClientData = {
            ...clientData,
            'id': clientId,
          };
        });
        
        if (mounted) {
          AppUtils.showSnackbar(context, 'Client updated successfully');
        }
      } else {
        // INSERT new client - check for duplicates first
        final existing = await DatabaseService.instance.getClientByName(clientName);
        if (existing != null) {
          if (mounted) {
            AppUtils.showSnackbar(
              context,
              'Client name already exists — select from search to edit or use "Save as New Record"',
              isError: true,
            );
          }
          return;
        }

        final clientId = await DatabaseService.instance.insertClient(clientData);
        
        setState(() {
          _currentClientData = {
            ...clientData,
            'id': clientId,
          };
          _isExistingClient = true;
          _setFieldsForExisting();
        });
        
        if (mounted) {
          AppUtils.showSnackbar(context, 'New client saved');
        }
      }
      
      await _loadExistingClients();
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(
          context,
          'Save failed: $e',
          isError: true,
        );
      }
    }
  }

  /// Equivalent to save_as_new() - saves as new client record (multi-site support)
  Future<void> _saveAsNew() async {
    if (!_formKey.currentState!.validate()) return;

    final clientName = _clientNameController.text.trim();
    final siteName = _siteNameController.text.trim();
    final location = _locationController.text.trim();
    final contact = _contactController.text.trim();
    final coords = _coordinatesController.text.trim();

    // Validate required fields
    final List<String> missing = [];
    if (clientName.isEmpty) missing.add('Client Name');
    if (siteName.isEmpty) missing.add('Site Name');
    if (location.isEmpty) missing.add('Location');
    
    if (missing.isNotEmpty) {
      AppUtils.showSnackbar(
        context,
        'Required: ${missing.join(', ')}',
        isError: true,
      );
      return;
    }

    // Validate coordinates if provided
    if (coords.isNotEmpty && !_validateCoords(coords)) {
      AppUtils.showSnackbar(
        context,
        'Invalid coordinates format (use: lat,lon)',
        isError: true,
      );
      return;
    }

    // Check if client already has this site name
    if (_isExistingClient && _currentClientData != null) {
      final existingSite = await DatabaseService.instance.getClientBySite(clientName, siteName);
      
      if (existingSite != null) {
        if (mounted) {
          AppUtils.showSnackbar(
            context,
            'Cannot save as new: Client "$clientName" already has site "$siteName". Use different site name.',
            isError: true,
          );
        }
        return;
      }
    }

    final clientData = {
      'name': clientName,
      'site_name': siteName,
      'location': location,
      'contact': contact,
      'location_coords': coords.isNotEmpty ? coords : null,
    };

    try {
      final clientId = await DatabaseService.instance.insertClient(clientData);
      
      setState(() {
        _currentClientData = {
          ...clientData,
          'id': clientId,
        };
        _isExistingClient = true;
        _setFieldsForExisting();
      });
      
      await _loadExistingClients();
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'Saved as new record (multi-site)');
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(
          context,
          'Save failed: $e',
          isError: true,
        );
      }
    }
  }

  /// Equivalent to proceed_to_system_registration() - navigates to system registration
  void _proceedToSystemRegistration() {
    if (_currentClientData == null) {
      AppUtils.showSnackbar(context, 'No client data to proceed', isError: true);
      return;
    }

    Navigator.pushNamed(
      context,
      '/system_registration',
      arguments: _currentClientData,
    );
    
    // Reset form for new searches when returning
    _resetFormForNewSearch();
  }

  // ==================== FORM RESET METHODS ====================
  
  /// Equivalent to reset_form_for_new_search() - resets form but keeps fields editable
  void _resetFormForNewSearch() {
    setState(() {
      _clientNameController.clear();
      _siteNameController.clear();
      _locationController.clear();
      _contactController.clear();
      _coordinatesController.clear();
      _gpsStatus = 'GPS: Ready';
      _currentClientData = null;
      _isExistingClient = false;
      _setFieldsForNew();
    });
    
    // Set focus to client field for quick typing
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  /// Equivalent to reset_form() - full reset when leaving screen
  void _resetForm() {
    _clientNameController.clear();
    _siteNameController.clear();
    _locationController.clear();
    _contactController.clear();
    _coordinatesController.clear();
    _gpsStatus = 'GPS: Ready';
    _currentClientData = null;
    _isExistingClient = false;
    _setFieldsForNew();
    _cleanupGps();
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop() async {
        _resetForm();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Column(
          children: [
            // Header with clock
            HeaderBox(
              title: 'Client Registration',
              includeClock: true,
            ),
            
            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.formPadding),
                  children: [
                    // Client Name with dropdown
                    RoundedTextField(
                      label: 'Client Name',
                      hint: 'Search or Type Client Name',
                      controller: _clientNameController,
                      required: true,
                      validator: (value) => AppUtils.validateRequired(value, 'Client Name'),
                      onChanged: _onClientNameChanged,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
                        onPressed: _showClientMenu,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Site Name
                    RoundedTextField(
                      label: 'Site Name',
                      hint: 'Enter site name',
                      controller: _siteNameController,
                      required: true,
                      validator: (value) => AppUtils.validateRequired(value, 'Site Name'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    RoundedTextField(
                      label: 'Location',
                      hint: 'Enter location',
                      controller: _locationController,
                      required: true,
                      validator: (value) => AppUtils.validateRequired(value, 'Location'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact
                    RoundedTextField(
                      label: 'Contact Number',
                      hint: 'Enter contact number',
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      validator: AppUtils.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    
                    // Coordinates with GPS button
                    Row(
                      children: [
                        Expanded(
                          child: RoundedTextField(
                            label: 'Coordinates',
                            hint: 'Enter lat,lon or tap button',
                            controller: _coordinatesController,
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _toggleGps,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gpsRunning ? AppColors.danger : AppColors.primary,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                            ),
                          ),
                          child: Icon(
                            _gpsRunning ? Icons.stop : Icons.gps_fixed,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _gpsStatus,
                      style: TextStyle(
                        color: AppColors.accent.withOpacity(0.7),
                        fontSize: 12,
                      ),
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
                    onPressed: () {
                      _resetForm();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutral,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: const Text('Back'),
                  ),
                  const Spacer(),
                  
                  // Save button
                  ElevatedButton(
                    onPressed: _saveButtonEnabled ? _saveOrUpdate : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isExistingClient
                          ? AppColors.warning  // Orange for UPDATE
                          : AppColors.accent,  // Blue for ADD
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: Text(_isExistingClient ? 'UPDATE' : 'SAVE'),
                  ),
                  const SizedBox(width: 8),
                  
                  // Save as New button
                  ElevatedButton(
                    onPressed: _saveAsNewButtonEnabled ? _saveAsNew : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: const Text('NEW SITE'),
                  ),
                  const SizedBox(width: 8),
                  
                  // Proceed button
                  ElevatedButton(
                    onPressed: _proceedButtonEnabled ? _proceedToSystemRegistration : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3399CC),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: const Text('ATTACH'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
