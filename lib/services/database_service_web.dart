// lib/services/database_service_web.dart
// Called ONLY when running in browser

import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

Future<void> initWebDatabase() async {
  databaseFactory = databaseFactoryFfiWeb;
}
