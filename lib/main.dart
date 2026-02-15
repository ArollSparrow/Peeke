// lib/main.dart
// Complete Flutter app entry point - equivalent to main.py
// Includes: Database init, theme, routes, backup scheduling

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'services/database_service.dart';
import 'services/backup_service.dart';
import 'routes.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web: skip SQLite entirely - runs in preview/demo mode
    // shared_preferences handles any web storage needed
    runApp(const PeekApp());
    return;
  }

  // Mobile only below this line
  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize database
  await DatabaseService.instance.init();

  runApp(const PeekApp());
}

class PeekApp extends StatefulWidget {
  const PeekApp({Key? key}) : super(key: key);

  @override
  State<PeekApp> createState() => _PeekAppState();
}

class _PeekAppState extends State<PeekApp> with WidgetsBindingObserver {
  Timer? _backupTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Schedule periodic backups (every 10 seconds initially, then hourly)
    // Backups only run on mobile - no file system on web
    if (!kIsWeb) {
      _scheduleBackups();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backupTimer?.cancel();
    super.dispose();
  }

  /// Schedule periodic backups
  void _scheduleBackups() {
    // Initial backup after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      BackupService.instance.createBackup();
    });

    // Then backup every hour
    _backupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      BackupService.instance.createBackup();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Backup when app is paused or stopped
    if (!kIsWeb &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached)) {
      BackupService.instance.createBackup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peek™ - System Management',
      debugShowCheckedModeBanner: false,

      // Dark theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Primary color - Sky Blue accent
        primaryColor: const Color(0xFF87CEEB),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF87CEEB),
          secondary: const Color(0xFF3399DC),
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF121212),
          error: const Color(0xFFE64D4D),
        ),

        // Scaffold background
        scaffoldBackgroundColor: const Color(0xFF121212),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF87CEEB)),
          titleTextStyle: TextStyle(
            color: Color(0xFF87CEEB),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Card theme
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF87CEEB),
            foregroundColor: Colors.black,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF87CEEB),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF87CEEB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF87CEEB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF87CEEB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE64D4D)),
          ),
          labelStyle: const TextStyle(color: Color(0xFF87CEEB)),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),

        // Checkbox theme
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF87CEEB);
            }
            return Colors.transparent;
          }),
          checkColor: MaterialStateProperty.all(Colors.black),
        ),

        // Icon theme
        iconTheme: const IconThemeData(
          color: Color(0xFF87CEEB),
        ),
      ),

      // Initial route
      initialRoute: Routes.landing,

      // Route generation
      onGenerateRoute: Routes.generateRoute,

      // Unknown route handler
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Text('Route ${settings.name} not found'),
          ),
        ),
      ),
    );
  }
}
