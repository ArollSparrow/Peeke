// lib/screens/landing/base_menu_screen.dart
// Reusable base menu screen template
// Used by: SystemsMenu, OperationsMenu, MaintenanceMenu, InventoryMenu

import 'package:flutter/material.dart';
import '../../utils/app_utils.dart';

/// Menu item data structure
class MenuItem {
  final String text;
  final IconData icon;
  final String route;
  final String? description;
  
  MenuItem(
    this.text,
    this.icon,
    this.route, {
    this.description,
  });
}

/// Base menu screen - Provides consistent UI for all submenu screens
class BaseMenuScreen extends StatelessWidget {
  final String title;
  final List<MenuItem> menuItems;
  final String? subtitle;

  const BaseMenuScreen({
    Key? key,
    required this.title,
    required this.menuItems,
    this.subtitle,
  }) : super(key: key);

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
              tooltip: 'Back',
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Subtitle (optional)
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    // Menu items
                    ...menuItems.map((item) => _buildMenuItem(context, item)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, item.route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent.withOpacity(0.85),
          foregroundColor: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon
            Icon(item.icon, size: 24),
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF1A1A1A).withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: const Color(0xFF1A1A1A).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
