// lib/screens/landing/inventory_menu.dart
// Inventory Management submenu
// Features: Add/view/issue spare parts, transaction history, reports

import 'package:flutter/material.dart';
import '../../routes.dart';
import 'base_menu_screen.dart';

class InventoryMenu extends StatelessWidget {
  const InventoryMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseMenuScreen(
      title: 'Inventory Management',
      subtitle: 'Spare parts and stock control',
      menuItems: [
        MenuItem(
          'Add Spare Part',
          Icons.add_box,
          Routes.addSparePart,
          description: 'Register new parts to inventory',
        ),
        MenuItem(
          'View Spare Parts',
          Icons.list_alt,
          Routes.viewSpareParts,
          description: 'Browse current stock levels',
        ),
        MenuItem(
          'Issue Spare Parts',
          Icons.output,
          Routes.issueSparePart,
          description: 'Issue parts for jobs',
        ),
        MenuItem(
          'Transaction Records',
          Icons.receipt_long,
          Routes.transactionHistory,
          description: 'View all part movements',
        ),
        MenuItem(
          'Inventory Reports',
          Icons.bar_chart,
          Routes.inventoryReports,
          description: 'Stock reports and analytics',
        ),
      ],
    );
  }
}
