// lib/screens/landing/maintenance_menu.dart
// Maintenance Services submenu
// Features: Generator, PV Inverter, Pump service records and history

import 'package:flutter/material.dart';
import '../../routes.dart';
import 'base_menu_screen.dart';

class MaintenanceMenu extends StatelessWidget {
  const MaintenanceMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseMenuScreen(
      title: 'Maintenance Services',
      subtitle: 'Service records and schedules',
      menuItems: [
        MenuItem(
          'Generator Service',
          Icons.power,
          Routes.generatorService,
          description: 'Generator maintenance records',
        ),
        MenuItem(
          'PV Inverter Service',
          Icons.solar_power,
          Routes.pvInverterService,
          description: 'Solar inverter maintenance',
        ),
        MenuItem(
          'Pump Inverter Service',
          Icons.water_drop,
          Routes.pumpInverterService,
          description: 'Water pump maintenance',
        ),
        MenuItem(
          'Service History',
          Icons.history,
          Routes.serviceHistory,
          description: 'View all past service records',
        ),
        MenuItem(
          'Due Services',
          Icons.alarm,
          Routes.dueServices,
          description: 'Upcoming maintenance schedule',
        ),
      ],
    );
  }
}
