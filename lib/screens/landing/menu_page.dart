// lib/screens/landing/menu_page.dart
// Main menu screen - Primary navigation hub
// Features: 4 main sections (Systems, Operations, Maintenance, Inventory)

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
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
              tooltip: 'Back to Landing',
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
                        letterSpacing: 1,
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Menu buttons
                    _buildMenuButton(
                      context,
                      'Systems',
                      Icons.dashboard,
                      Routes.systemsMenu,
                      'Manage clients and systems',
                    ),
                    
                    _buildMenuButton(
                      context,
                      'Operations',
                      Icons.work_outline,
                      Routes.operationsMenu,
                      'Record and view operations',
                    ),
                    
                    _buildMenuButton(
                      context,
                      'Maintenance',
                      Icons.build_circle_outlined,
                      Routes.maintenanceMenu,
                      'Service and maintenance records',
                    ),
                    
                    _buildMenuButton(
                      context,
                      'Inventory',
                      Icons.inventory_2_outlined,
                      Routes.inventoryMenu,
                      'Spare parts management',
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
    String description,
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
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 28),
            ),
            
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF1A1A1A).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
