// lib/screens/landing/operations_menu.dart
// Operations Management submenu
// Features: Record operations, View operation reports

import 'package:flutter/material.dart';
import '../../routes.dart';
import 'base_menu_screen.dart';

class OperationsMenu extends StatelessWidget {
  const OperationsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseMenuScreen(
      title: 'Operations',
      subtitle: 'Record and manage system operations',
      menuItems: [
        MenuItem(
          'Record Operations',
          Icons.edit_note,
          Routes.operationsRecord,
          description: 'Log new operations (start/stop/single)',
        ),
        MenuItem(
          'View Reports',
          Icons.assessment,
          Routes.operationsReportsMenu,
          description: 'View operation history and reports',
        ),
      ],
    );
  }
}
