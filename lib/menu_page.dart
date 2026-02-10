// lib/screens/landing/menu_page.dart
// Main menu screen - equivalent to MenuPageScreen in landing_mainpage.py
// Features: Systems, Operations, Maintenance, Inventory navigation

import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../utils/app_utils.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
              ),
            ),
          ),
          
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 30,
                color: AppColors.accent,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      'Main Menu',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Menu buttons
                    _buildMenuButton(
                      context,
                      'Systems',
                      Icons.dashboard,
                      Routes.systemsMenu,
                    ),
                    
                    _buildMenuButton(
                      context,
                      'Operations',
                      Icons.work,
                      Routes.operationsMenu,
                    ),
                    
                    _buildMenuButton(
                      context,
                      'Maintenance',
                      Icons.build,
                      Routes.maintenanceMenu,
                    ),
                    
                    _buildMenuButton(
                      context,
                      'Inventory',
                      Icons.inventory,
                      Routes.inventoryMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    String route,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent.withOpacity(0.85),
          foregroundColor: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
