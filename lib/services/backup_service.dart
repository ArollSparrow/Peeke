import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

class BackupService {
  static final BackupService instance = BackupService._private();
  BackupService._private();

  Future<bool> createBackup() async {
    if (kIsWeb) {
      print('🕸️ Web mode → Backup feature is mocked (UI/UX testing only)');
      return false;
    }
    // Your original mobile code can go here later
    return false;
  }

  Future<List<dynamic>> listBackups() async {
    if (kIsWeb) return [];
    return [];
  }

  Future<bool> restoreBackup(dynamic backupFile) async {
    if (kIsWeb) return false;
    return false;
  }

  Future<int> getBackupSize(dynamic backupFile) async => 0;

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
