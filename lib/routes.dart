// lib/routes.dart
import 'package:flutter/material.dart';

// Landing and Menu
import 'screens/landing/landing_page.dart';
import 'screens/landing/menu_page.dart';
import 'screens/landing/systems_menu.dart';
import 'screens/landing/operations_menu.dart';
import 'screens/landing/maintenance_menu.dart';
import 'screens/landing/inventory_menu.dart';

// Registration Screens
import 'screens/registration/client_registration_screen.dart';
import 'screens/registration/system_registration_screen.dart';
import 'screens/registration/update_system_screen.dart';
import 'screens/registration/select_system_screen.dart';
import 'screens/registration/delete_system_screen.dart';

// Operations Screens
import 'screens/operations/operations_record_screen.dart';
import 'screens/operations/operations_reports_menu_screen.dart';
import 'screens/operations/operations_reports_display_screen.dart';

class Routes {
  static const String landing = '/';
  static const String menu = '/menu';
  static const String systemsMenu = '/systems_menu';
  static const String operationsMenu = '/operations_menu';
  static const String maintenanceMenu = '/maintenance_menu';
  static const String inventoryMenu = '/inventory_menu';

  static const String clientRegistration = '/client_registration';
  static const String systemRegistration = '/system_registration';
  static const String selectSystem = '/select_system';
  static const String updateSystem = '/update_system';
  static const String deleteSystem = '/delete_system';

  static const String operationsRecord = '/operations_record';
  static const String operationsReportsMenu = '/operations_reports_menu';
  static const String operationsReportsDisplay = '/operations_reports_display';

  static const String dashboard = '/dashboard';

  static const String addSparePart = '/add_spare_part';
  static const String viewSpareParts = '/view_spare_parts';
  static const String issueSparePart = '/issue_spare_part';
  static const String transactionHistory = '/transaction_history';
  static const String inventoryReports = '/inventory_reports';

  static const String generatorService = '/generator_service';
  static const String pvInverterService = '/pv_inverter_service';
  static const String pumpInverterService = '/pump_inverter_service';
  static const String serviceHistory = '/service_history';
  static const String dueServices = '/due_services';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
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

      // Dashboard, Inventory, Maintenance - inline placeholder (no separate files)
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholder('Dashboard', Icons.dashboard),
        );

      case addSparePart:
      case viewSpareParts:
      case issueSparePart:
      case transactionHistory:
      case inventoryReports:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholder(
            _routeToTitle(settings.name ?? ''),
            Icons.inventory_2,
          ),
        );

      case generatorService:
      case pvInverterService:
      case pumpInverterService:
      case serviceHistory:
      case dueServices:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholder(
            _routeToTitle(settings.name ?? ''),
            Icons.build,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholder('Page Not Found', Icons.error),
        );
    }
  }

  static Widget _buildPlaceholder(String title, IconData icon) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color(0xFF3399CC)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Coming Soon',
              style: TextStyle(color: Color(0xFF888888), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static String _routeToTitle(String route) {
    return route
        .replaceAll('/', '')
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
