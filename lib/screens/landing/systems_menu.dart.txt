// lib/screens/landing/systems_menu.dart
// Systems Management submenu
// Features: Dashboard, Client/System Registration, View/Update/Delete systems

import 'package:flutter/material.dart';
import '../../routes.dart';
import 'base_menu_screen.dart';

class SystemsMenu extends StatelessWidget {
  const SystemsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseMenuScreen(
      title: 'Systems Management',
      subtitle: 'Manage clients and their systems',
      menuItems: [
        MenuItem(
          'Dashboard',
          Icons.dashboard,
          Routes.dashboard,
          description: 'System overview and statistics',
        ),
        MenuItem(
          'Register Client & System',
          Icons.add_business,
          Routes.clientRegistration,
          description: 'Add new client and register systems',
        ),
        MenuItem(
          'View Systems',
          Icons.list_alt,
          Routes.selectSystem,
          description: 'Browse and search all systems',
        ),
      ],
    );
  }
}
