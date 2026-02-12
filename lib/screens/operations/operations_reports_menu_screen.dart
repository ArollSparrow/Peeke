// lib/screens/operations/operations_reports_menu_screen_complete.dart
// COMPLETE translation of OperationsReportsMenuScreen from operations.py
// Part 2 of 3: Operations Reports Menu with period selection

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_utils.dart';

class OperationsReportsMenuScreen extends StatefulWidget {
  const OperationsReportsMenuScreen({super.key};

  @override
  State<OperationsReportsMenuScreen> createState() =>
      _OperationsReportsMenuScreenState();
}

class _OperationsReportsMenuScreenState
    extends State<OperationsReportsMenuScreen> {
  // Report periods
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  // ==================== NAVIGATION METHODS ====================

  /// Equivalent to open_period_picker() - opens date picker for selected period
  Future<void> _openPeriodPicker(String period) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.black,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      _showReport(period, pickedDate);
    }
  }

  /// Equivalent to show_report() - navigates to display screen with period and date
  void _showReport(String period, DateTime date) {
    Navigator.pushNamed(
      context,
      '/operations_reports_display',
      arguments: {
        'period': period.toLowerCase(),
        'date': DateFormat('yyyy-MM-dd').format(date),
      },
    );
  }

  // ==================== BUTTON BUILDER ====================

  /// Equivalent to _create_report_button() - creates a report period button
  Widget _createReportButton(String text, {bool isBack = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          if (isBack) {
            Navigator.pop(context);
          } else {
            _openPeriodPicker(text);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isBack ? AppColors.neutral : const Color(0xFF3399CC),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: Text(
          isBack ? text : '$text Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBack ? FontWeight.normal : FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==================== BUILD METHOD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          height: MediaQuery.of(context).size.height * 0.88,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A26).withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Title
              Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'Operations Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Period buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ..._periods.map((period) => _createReportButton(period)),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Back button
              _createReportButton('Back', isBack: true),
            ],
          ),
        ),
      ),
    );
  }
}
