// lib/screens/registration/delete_system_screen_complete.dart
// COMPLETE translation of DeleteRegistrationSystemScreen from registration.py
// Part 5/5: Delete System with confirmation dialog

import 'package:flutter/material.dart';
import '../../utils/app_utils.dart';
import '../../services/database_service.dart';

class DeleteSystemScreenComplete extends StatefulWidget {
  final int? systemId;

  const DeleteSystemScreenComplete({
    Key? key,
    this.systemId,
  }) : super(key: key);

  @override
  State<DeleteSystemScreenComplete> createState() => _DeleteSystemScreenCompleteState();
}

class _DeleteSystemScreenCompleteState extends State<DeleteSystemScreenComplete> {
  int? _systemId;
  Map<String, dynamic>? _systemData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _systemId = widget.systemId;
    if (_systemId != null) {
      _loadSystem(_systemId!);
    }
  }

  // ==================== LOAD SYSTEM ====================
  
  /// Equivalent to load_system() - loads system details for confirmation
  Future<void> _loadSystem(int systemId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DatabaseService.instance.getSystemById(systemId);
      
      if (data == null) {
        if (mounted) {
          AppUtils.showSnackbar(context, 'System not found', isError: true);
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _systemData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(context, 'Error loading system: $e', isError: true);
        Navigator.pop(context);
      }
    }
  }

  // ==================== DELETE CONFIRMATION ====================
  
  /// Equivalent to confirm_delete() - shows confirmation dialog
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Confirm Delete',
          style: TextStyle(color: AppColors.danger),
        ),
        content: const Text(
          'Are you sure? This cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _performDelete();
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

  // ==================== PERFORM DELETE ====================
  
  /// Equivalent to perform_delete() - executes the delete operation
  Future<void> _performDelete() async {
    if (_systemId == null) {
      AppUtils.showSnackbar(context, 'No system to delete', isError: true);
      return;
    }

    try {
      await DatabaseService.instance.deleteSystem(_systemId!);
      
      if (mounted) {
        AppUtils.showSnackbar(context, 'System deleted successfully');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackbar(context, 'Delete failed: $e', isError: true);
      }
    }
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    // Format system details
    String subtitle = 'System: Not selected';
    String details = 'No system loaded';
    
    if (_systemData != null) {
      subtitle = 'System ID: ${_systemData!['id']}';
      
      final capacityValue = _systemData!['capacity'] ?? '';
      final capacityUnit = _systemData!['capacity_unit'] ?? '';
      final capacityStr = capacityValue != '' && capacityUnit != ''
          ? '$capacityValue $capacityUnit'
          : capacityValue.toString();
      
      details = '''
Client: ${_systemData!['client_name'] ?? 'N/A'}
Site: ${_systemData!['client_site'] ?? 'N/A'}
Location: ${_systemData!['client_location'] ?? 'N/A'}
Type: ${_systemData!['type'] ?? 'N/A'}
Serial: ${_systemData!['serial_number'] ?? 'N/A'}
Model: ${_systemData!['model'] ?? 'N/A'}
Capacity: $capacityStr''';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Header with warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
            ),
            child: Column(
              children: [
                // Title (red color for delete)
                Text(
                  'Delete System',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Warning
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'Warning: This action cannot be undone!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // System details
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          details,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.center,
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
                // Back button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutral,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Delete button (disabled until loaded)
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _systemData != null ? _confirmDelete : null,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text(
                      'CONFIRM DELETE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
