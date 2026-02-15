// lib/services/database_service_stub.dart
// Called on Android/iOS - database init handled in main() directly

Future<void> initWebDatabase() async {
  // No-op on mobile - sqflite handles it natively
}
