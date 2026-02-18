// lib/utils/app_utils.dart - Comprehensive utilities translated from utils.py

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// ====================== COLOR SCHEME ======================
class AppColors {
  static const Color primary = Color(0xFF3399DC);
  static const Color accent = Color(0xFF87CEEB);
  static const Color backgroundOverlay = Color(0x59000000);
  static const Color textLight = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color success = Color(0xE533CC33);
  static const Color warning = Color(0xFFD9A633);
  static const Color danger = Color(0xE5E64D4D);
  static const Color neutral = Color(0xE54D4D59);
  
  // Additional colors for UI elements
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color inputBackground = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF3A3A3A);
}

// ====================== CONSTANTS ======================
class AppConstants {
  static const double formPadding = 20.0;
  static const double formSpacing = 20.0;
  static const double buttonHeight = 60.0;
  static const double fieldHeight = 50.0;
  static const double rowHeight = 50.0;
  static const double headerRowHeight = 60.0;
  static const double borderRadius = 20.0;
  static const double iconSize = 24.0;
}

// ====================== REUSABLE WIDGETS ======================

/// Rounded text field styled like KivyMD RoundedMDTextField
class RoundedTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final Widget? suffixIcon;
  final bool required;

  const RoundedTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.suffixIcon,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: required && label != null ? '$label *' : label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

/// Dropdown text field with menu icon
class DropdownTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool required;

  const DropdownTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.onTap,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedTextField(
      label: label,
      hint: hint,
      controller: controller,
      readOnly: true,
      required: required,
      suffixIcon: Icon(
        Icons.arrow_drop_down,
        color: AppColors.accent,
        size: 28,
      ),
    );
  }
}

/// Header box with title, subtitle, and optional clock
class HeaderBox extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool includeClock;
  final Color? titleColor;

  const HeaderBox({
    Key? key,
    required this.title,
    this.subtitle,
    this.includeClock = true,
    this.titleColor,
  }) : super(key: key);

  @override
  State<HeaderBox> createState() => _HeaderBoxState();
}

class _HeaderBoxState extends State<HeaderBox> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    if (widget.includeClock) {
      _updateClock();
      Future.delayed(Duration.zero, _startClock);
    }
  }

  void _startClock() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateClock();
        _startClock();
      }
    });
  }

  void _updateClock() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('EEEE, dd MMM yyyy • hh:mm a').format(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.titleColor ?? AppColors.accent,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
          if (widget.includeClock) ...[
            const SizedBox(height: 8),
            Text(
              _currentTime,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accent.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Form row with label and field
class FormRow extends StatelessWidget {
  final String labelText;
  final Widget fieldWidget;
  final double labelWidth;
  final bool showRequired;

  const FormRow({
    Key? key,
    required this.labelText,
    required this.fieldWidget,
    this.labelWidth = 0.35,
    this.showRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayLabel = showRequired ? '$labelText *' : labelText;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: (labelWidth * 10).toInt(),
            child: ElevatedButton(
              onPressed: () {
                // Focus the field (if applicable)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.accent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.accent),
                ),
              ),
              child: Text(
                displayLabel,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: ((1 - labelWidth) * 10).toInt(),
            child: fieldWidget,
          ),
        ],
      ),
    );
  }
}

/// Date/Time row with picker
class DateTimeRow extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isDate;
  final double labelWidth;

  const DateTimeRow({
    Key? key,
    required this.labelText,
    required this.controller,
    this.isDate = true,
    this.labelWidth = 0.35,
  }) : super(key: key);

  Future<void> _pickDate(BuildContext context) async {
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

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: (labelWidth * 10).toInt(),
            child: Text(
              labelText,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: ((1 - labelWidth) * 10).toInt(),
            child: Row(
              children: [
                Expanded(
                  child: RoundedTextField(
                    controller: controller,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isDate ? Icons.calendar_today : Icons.access_time,
                    color: AppColors.accent,
                  ),
                  onPressed: () {
                    if (isDate) {
                      _pickDate(context);
                    } else {
                      _pickTime(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== UTILITY FUNCTIONS ======================

class AppUtils {
  /// Get database path
  static Future<String> getDbPath() async {
    if (kIsWeb) return 'peekopv1.db';
    final directory = await getApplicationDocumentsDirectory();
    final dbDir = Directory('${directory.path}/Database');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    return '${dbDir.path}/peekopv1.db';
  }

  /// Get export directory
  static Future<String> getExportDirectory([String category = 'Exports']) async {
    if (kIsWeb) return category;
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/Exports/$category');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  /// Format date for display (dd-MM-yyyy)
  static String formatDateDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'None') {
      return 'N/A';
    }
    try {
      // Try parsing from database format (yyyy-MM-dd)
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      try {
        // Already in display format
        return dateStr;
      } catch (e) {
        return dateStr;
      }
    }
  }

  /// Format date for database (yyyy-MM-dd)
  static String formatDateDb(String dateStr) {
    try {
      final date = DateFormat('dd-MM-yyyy').parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Get today's date formatted
  static String getTodayFormatted() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  /// Show snackbar
  static void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }
}

// ====================== BASE SCREEN ======================

/// Base screen widget with background and common functionality
abstract class BaseScreen extends StatelessWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Background (you can add asset image here)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E1E1E),
                  Color(0xFF121212),
                ],
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: AppColors.backgroundOverlay,
          ),
          // Content
          SafeArea(
            child: buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context);
}

