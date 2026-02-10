// lib/services/backup_service.dart
// Database backup and recovery service - equivalent to BackupManager in backup_recovery.py

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService instance = BackupService._internal();
  BackupService._internal();

  /// Create a database backup
  Future<bool> createBackup() async {
    try {
      // Get database file
      final dbPath = await DatabaseService.instance.getDatabasePath();
      final dbFile = File(dbPath);
      
      if (!await dbFile.exists()) {
        debugPrint('Database file not found: $dbPath');
        return false;
      }

      // Get backup directory
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Create backup filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupPath = path.join(backupDir.path, 'peekopv1_backup_$timestamp.db');
      
      // Copy database file to backup location
      await dbFile.copy(backupPath);
      
      debugPrint('Backup created successfully: $backupPath');
      
      // Clean old backups (keep last 10)
      await _cleanOldBackups(backupDir);
      
      return true;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      return false;
    }
  }

  /// Get backup directory
  Future<Directory> _getBackupDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDocDir.path, 'Backups'));
  }

  /// Clean old backups (keep last 10)
  Future<void> _cleanOldBackups(Directory backupDir) async {
    try {
      final backups = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();

      if (backups.length > 10) {
        // Sort by modification time
        backups.sort((a, b) => 
          a.statSync().modified.compareTo(b.statSync().modified)
        );

        // Delete oldest backups
        for (var i = 0; i < backups.length - 10; i++) {
          await backups[i].delete();
          debugPrint('Deleted old backup: ${backups[i].path}');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning old backups: $e');
    }
  }

  /// List all backups
  Future<List<File>> listBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) {
        return [];
      }

      final backups = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();

      // Sort by modification time (newest first)
      backups.sort((a, b) => 
        b.statSync().modified.compareTo(a.statSync().modified)
      );

      return backups;
    } catch (e) {
      debugPrint('Error listing backups: $e');
      return [];
    }
  }

  /// Restore database from backup
  Future<bool> restoreBackup(File backupFile) async {
    try {
      if (!await backupFile.exists()) {
        debugPrint('Backup file not found: ${backupFile.path}');
        return false;
      }

      // Close database connection
      await DatabaseService.instance.close();

      // Get database path
      final dbPath = await DatabaseService.instance.getDatabasePath();
      final dbFile = File(dbPath);

      // Create backup of current database before restore
      if (await dbFile.exists()) {
        final tempBackupPath = '$dbPath.restore_backup';
        await dbFile.copy(tempBackupPath);
      }

      // Copy backup file to database location
      await backupFile.copy(dbPath);

      // Reinitialize database
      await DatabaseService.instance.init();

      debugPrint('Database restored successfully from: ${backupFile.path}');
      return true;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  /// Get backup file size
  Future<int> getBackupSize(File backupFile) async {
    try {
      return await backupFile.length();
    } catch (e) {
      debugPrint('Error getting backup size: $e');
      return 0;
    }
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
