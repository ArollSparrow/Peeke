// lib/routes.dart
// Complete route definitions for the entire app
// Includes: Registration, Operations, Dashboard, Inventory, Maintenance

import 'package:flutter/material.dart';

// Landing and Menu
import 'screens/landing/landing_page.dart';
import 'screens/landing/menu_page.dart';
import 'screens/landing/systems_menu.dart';
import 'screens/landing/operations_menu.dart';
import 'screens/landing/maintenance_menu.dart';
import 'screens/landing/inventory_menu.dart';

// Registration Screens (COMPLETE)
import 'screens/registration/client_registration_screen.dart';
import 'screens/registration/system_registration_screen.dart';
import 'screens/registration/update_system_screen.dart';
import 'screens/registration/select_system_screen.dart';
import 'screens/registration/delete_system_screen.dart';

// Operations Screens (COMPLETE)
import 'screens/operations/operations_record_screen.dart';
import 'screens/operations/operations_reports_menu_screen.dart';
import 'screens/operations/operations_reports_display_screen.dart';


class Routes {
  // Landing and Menu routes
  static const String landing = '/';
  static const String menu = '/menu';
  static const String systemsMenu = '/systems_menu';
  static const String operationsMenu = '/operations_menu';
  static const String maintenanceMenu = '/maintenance_menu';
  static const String inventoryMenu = '/inventory_menu';
  
  // Registration routes
  static const String clientRegistration = '/client_registration';
  static const String systemRegistration = '/system_registration';
  static const String selectSystem = '/select_system';
  static const String updateSystem = '/update_system';
  static const String deleteSystem = '/delete_system';
  
  // Operations routes
  static const String operationsRecord = '/operations_record';
  static const String operationsReportsMenu = '/operations_reports_menu';
  static const String operationsReportsDisplay = '/operations_reports_display';
  
  // Dashboard route
  static const String dashboard = '/dashboard';
  
  // Inventory routes (placeholders)
  static const String addSparePart = '/add_spare_part';
  static const String viewSpareParts = '/view_spare_parts';
  static const String issueSparePart = '/issue_spare_part';
  static const String transactionHistory = '/transaction_history';
  static const String inventoryReports = '/inventory_reports';
  
  // Maintenance routes (placeholders)
  static const String generatorService = '/generator_service';
  static const String pvInverterService = '/pv_inverter_service';
  static const String pumpInverterService = '/pump_inverter_service';
  static const String serviceHistory = '/service_history';
  static const String dueServices = '/due_services';

  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments
    final args = settings.arguments;

    switch (settings.name) {
      // ==================== LANDING & MENU ====================
      case landing:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      
      case menu:
        return MaterialPageRoute(builder: (_) => const MenuPage());
      
      case systemsMenu:
        return MaterialPageRoute(builder: (_) => const SystemsMenu());
      
      case operationsMenu:
        return MaterialPageRoute(builder: (_) => const OperationsMenu());
      
      case maintenanceMenu:
        return MaterialPageRoute(builder: (_) => const MaintenanceMenu());
      
      case inventoryMenu:
        return MaterialPageRoute(builder: (_) => const InventoryMenu());

      // ==================== REGISTRATION (COMPLETE) ====================
      case clientRegistration:
        return MaterialPageRoute(
          builder: (_) => const ClientRegistrationScreen(),
        );
      
      case systemRegistration:
        final clientData = args as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SystemRegistrationScreen(clientData: clientData),
        );
      
      case selectSystem:
        return MaterialPageRoute(
          builder: (_) => const SelectSystemScreen(),
        );
      
      case updateSystem:
        final systemId = args as int?;
        return MaterialPageRoute(
          builder: (_) => UpdateSystemScreen(systemId: systemId),
        );
      
      case deleteSystem:
        final systemId = args as int?;
        return MaterialPageRoute(
          builder: (_) => DeleteSystemScreen(systemId: systemId),
        );

      // ==================== OPERATIONS (COMPLETE) ====================
      case operationsRecord:
        return MaterialPageRoute(
          builder: (_) => const OperationsRecordScreen(),
        );
      
      case operationsReportsMenu:
        return MaterialPageRoute(
          builder: (_) => const OperationsReportsMenuScreen(),
        );
      
      case operationsReportsDisplay:
        final reportArgs = args as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OperationsReportsDisplayScreen(
            arguments: reportArgs,
          ),
        );

      // ==================== DASHBOARD (PLACEHOLDER) ====================
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPlaceholder(),
        );

      // ==================== INVENTORY (PLACEHOLDERS) ====================
      case addSparePart:
      case viewSpareParts:
      case issueSparePart:
      case transactionHistory:
      case inventoryReports:
        return MaterialPageRoute(
          builder: (_) => InventoryPlaceholder(
            featureName: _getFeatureName(settings.name ?? ''),
          ),
        );

      // ==================== MAINTENANCE (PLACEHOLDERS) ====================
      case generatorService:
      case pvInverterService:
      case pumpInverterService:
      case serviceHistory:
      case dueServices:
        return MaterialPageRoute(
          builder: (_) => MaintenancePlaceholder(
            featureName: _getFeatureName(settings.name ?? ''),
          ),
        );

      // ==================== DEFAULT ====================
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Get feature name from route
  static String _getFeatureName(String route) {
    final parts = route.split('/');
    if (parts.length > 1) {
      return parts.last
          .split('_')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    return 'Feature';
  }
}
