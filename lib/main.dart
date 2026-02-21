// lib/main.dart
// Exact version from your successful "Ready State" deployment (the one that went live)
// This is our stable current main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'services/database_service.dart';
import 'services/backup_service.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    runApp(const PeekApp());
    return;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

  void _scheduleBackups() {
    Future.delayed(const Duration(seconds: 10), () {
      BackupService.instance.createBackup();
    });

    _backupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      BackupService.instance.createBackup();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!kIsWeb &&
        (state == AppLifecycleState.paused || state == AppLifecycleState.detached)) {
      BackupService.instance.createBackup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peek™ - System Management',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        primaryColor: const Color(0xFF87CEEB),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF87CEEB),
          secondary: const Color(0xFF3399DC),
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF121212),
          error: const Color(0xFFE64D4D),
        ),

        scaffoldBackgroundColor: const Color(0xFF121212),

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

        // Classic CardTheme - the one that succeeded in your "Ready State" deployment
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

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

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF87CEEB),
          ),
        ),

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

        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF87CEEB);
            }
            return Colors.transparent;
          }),
          checkColor: MaterialStateProperty.all(Colors.black),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFF87CEEB),
        ),
      ),

      initialRoute: Routes.landing,
      onGenerateRoute: Routes.generateRoute,
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
