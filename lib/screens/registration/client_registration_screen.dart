// lib/screens/registration/client_registration_screen.dart
// Translated from ClientRegistrationScreen in registration.py

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';

class ClientRegistrationScreen extends StatefulWidget {
  const ClientRegistrationScreen({super.key});

  @override
  State<ClientRegistrationScreen> createState() => _ClientRegistrationScreenState();
}

class _ClientRegistrationScreenState extends State<ClientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for all fields
  final _clientNameController = TextEditingController();
  final _siteNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _coordinatesController = TextEditingController();
  
  // State variables
  bool _isExistingClient = false;
  int? _currentClientId;
  Map<String, dynamic>? _currentClientData;
  bool _gpsRunning = false;
  String _gpsStatus = 'GPS: Ready';
  List<Map<String, dynamic>> _existingClients = [];
  
  // Save buttons state
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
    super.dispose();
  }

  Future<void> _loadExistingClients() async {
    final clients = await DatabaseService.instance.getClients();
    setState(() {
      _existingClients = clients;
    });
  }

  Future<void> _checkGpsPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      setState(() {
        _gpsStatus = 'GPS: Unavailable';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_gpsRunning) {
      setState(() {
        _gpsRunning = false;
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
      );
      
      setState(() {
        _coordinatesController.text = '${position.latitude}, ${position.longitude}';
        _gpsStatus = 'GPS: Location acquired';
        _gpsRunning = false;
      });
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'Location acquired successfully');
      }
    } catch (e) {
      setState(() {
        _gpsStatus = 'GPS: Error - $e';
        _gpsRunning = false;
      });
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'Failed to get location: $e', isError: true);
      }
    }
  }

  void _onClientNameChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _isExistingClient = false;
        _currentClientData = null;
        _currentClientId = null;
        _clearFields();
        _updateButtonStates();
      });
      return;
    }

    // Check for exact match with existing clients
    final exactMatch = _existingClients.firstWhere(
      (client) => client['name'].toString().toLowerCase() == value.toLowerCase(),
      orElse: () => {},
    );

    if (exactMatch.isNotEmpty) {
      _loadExistingClientData(exactMatch);
    } else {
      setState(() {
        _isExistingClient = false;
        _currentClientData = null;
        _currentClientId = null;
        _updateButtonStates();
      });
    }
  }

  void _loadExistingClientData(Map<String, dynamic> clientData) {
    setState(() {
      _isExistingClient = true;
      _currentClientData = clientData;
      _currentClientId = clientData['id'];
      
      _siteNameController.text = clientData['site_name'] ?? '';
      _locationController.text = clientData['location'] ?? '';
      _contactController.text = clientData['contact'] ?? '';
      _coordinatesController.text = clientData['location_coords'] ?? '';
      
      _updateButtonStates();
    });

    if (mounted) {
      AppUtils.showSnackbar(context, 'Existing client loaded: ${clientData['name']}');
    }
  }

  void _clearFields() {
    _siteNameController.clear();
    _locationController.clear();
    _contactController.clear();
    _coordinatesController.clear();
  }

  void _updateButtonStates() {
    setState(() {
      _saveButtonEnabled = !_isExistingClient;
      _saveAsNewButtonEnabled = _isExistingClient;
      _proceedButtonEnabled = _currentClientId != null;
    });
  }

  Future<void> _saveOrUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final clientData = {
      'name': _clientNameController.text.trim(),
      'site_name': _siteNameController.text.trim(),
      'location': _locationController.text.trim(),
      'contact': _contactController.text.trim(),
      'location_coords': _coordinatesController.text.trim(),
    };

    try {
      if (_isExistingClient && _currentClientId != null) {
        // Update existing client
        await DatabaseService.instance.updateClient(_currentClientId!, clientData);
        if (mounted) {
          AppUtils.showSnackbar(context, 'Client updated successfully');
        }
      } else {
        // Insert new client
        final clientId = await DatabaseService.instance.insertClient(clientData);
        setState(() {
          _currentClientId = clientId;
          _isExistingClient = true;
          _proceedButtonEnabled = true;
        });
        if (mounted) {
          AppUtils.showSnackbar(context, 'Client saved successfully');
        }
      }
      
      await _loadExistingClients();
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error saving client: $e', isError: true);
      }
    }
  }

  Future<void> _saveAsNew() async {
    if (!_formKey.currentState!.validate()) return;

    final clientData = {
      'name': _clientNameController.text.trim(),
      'site_name': _siteNameController.text.trim(),
      'location': _locationController.text.trim(),
      'contact': _contactController.text.trim(),
      'location_coords': _coordinatesController.text.trim(),
    };

    try {
      final clientId = await DatabaseService.instance.insertClient(clientData);
      setState(() {
        _currentClientId = clientId;
        _isExistingClient = true;
        _proceedButtonEnabled = true;
        _saveAsNewButtonEnabled = false;
        _saveButtonEnabled = false;
      });
      
      await _loadExistingClients();
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'New site saved successfully');
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error saving new site: $e', isError: true);
      }
    }
  }

  void _proceedToSystemRegistration() {
    if (_currentClientId == null) {
      AppUtils.showSnackbar(context, 'Please save client first', isError: true);
      return;
    }

    Navigator.pushNamed(
      context,
      '/system_registration',
      arguments: {
        'client_id': _currentClientId,
        'client_name': _clientNameController.text.trim(),
      },
    );
  }

  void _showClientMenu() {
    if (_existingClients.isEmpty) {
      AppUtils.showSnackbar(context, 'No existing clients found');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      builder: (context) => ListView.builder(
        itemCount: _existingClients.length,
        itemBuilder: (context, index) {
          final client = _existingClients[index];
          return ListTile(
            title: Text(
              client['name'] ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              client['location'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Navigator.pop(context);
              _clientNameController.text = client['name'];
              _loadExistingClientData(client);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Header
          HeaderBox(
            title: 'Client Registration',
            includeClock: true,
          ),
          
          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.formPadding),
                children: [
                  // Client Name
                  RoundedTextField(
                    label: 'Client Name',
                    hint: 'Enter client name',
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
                          hint: 'Latitude, Longitude',
                          controller: _coordinatesController,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: Icon(_gpsRunning ? Icons.stop : Icons.gps_fixed),
                        label: Text(_gpsRunning ? 'Stop' : 'GPS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gpsRunning ? AppColors.danger : AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
                const Spacer(),
                
                // Save button
                ElevatedButton(
                  onPressed: _saveButtonEnabled ? _saveOrUpdate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('SAVE'),
                ),
                const SizedBox(width: 8),
                
                // Save as New button
                ElevatedButton(
                  onPressed: _saveAsNewButtonEnabled ? _saveAsNew : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('NEW SITE'),
                ),
                const SizedBox(width: 8),
                
                // Proceed button
                ElevatedButton(
                  onPressed: _proceedButtonEnabled ? _proceedToSystemRegistration : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3399CC),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('ATTACH'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
