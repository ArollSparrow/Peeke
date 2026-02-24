// lib/screens/landing/landing_page.dart
// Main landing screen - Branded entry point for Peek™ app
// Features: App branding, menu access, version info, gradient background

import 'package:flutter/material.dart';
import '../../routes.dart';
import '../../utils/app_utils.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - Blue theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E), // Dark blue
                  Color(0xFF16213E), // Medium blue
                  Color(0xFF0F3460), // Lighter blue
                ],
              ),
            ),
          ),
          
          // Menu button at top-left
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.menu,
                size: 40,
                color: AppColors.accent,
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.menu);
              },
              tooltip: 'Main Menu',
            ),
          ),
          
          // Main content - Centered branding
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // App name card
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // App name
                      Text(
                        'Peeke™',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Tagline
                      Text(
                        'Every drop counts',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.accent.withOpacity(0.9),
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Tap to continue hint
                      Text(
                        'Tap menu to start',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),
              ],
            ),
          ),
          
          // Version info at bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Large watermark
                Text(
                  'Peeke™',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Version
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Copyright
                Text(
                  '© 2026 Peeke Systems',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
