import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../services/encryption_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  static BackupService get instance => _instance;
  BackupService._internal();

  final _encryptionService = EncryptionService();

  Future<String> createEncryptedBackup() async {
    try {
      final passwords = await StorageService.instance.getAllPasswords();
      
      final backupData = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'app': 'HiddenPW',
        'encrypted': true,
        'passwordCount': passwords.length,
        'passwords': passwords.map((password) => {
          'id': password.id,
          'title': password.title,
          'username': password.username,
          'password': password.password, // This will be encrypted by storage service
          'url': password.url,
          'notes': password.notes,
          'createdAt': password.createdAt.millisecondsSinceEpoch,
          'updatedAt': password.updatedAt.millisecondsSinceEpoch,
          'isCompromised': password.isCompromised,
        }).toList(),
      };

      return jsonEncode(backupData);
    } catch (e) {
      throw Exception('Backup creation failed: $e');
    }
  }

  Future<String> createPlainBackup() async {
    try {
      final passwords = await StorageService.instance.getAllPasswords();
      
      final backupData = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'app': 'HiddenPW',
        'encrypted': false,
        'passwordCount': passwords.length,
        'passwords': passwords.map((password) => {
          'id': password.id,
          'title': password.title,
          'username': password.username,
          'password': password.password,
          'url': password.url,
          'notes': password.notes,
          'createdAt': password.createdAt.millisecondsSinceEpoch,
          'updatedAt': password.updatedAt.millisecondsSinceEpoch,
          'isCompromised': password.isCompromised,
        }).toList(),
      };

      return jsonEncode(backupData);
    } catch (e) {
      throw Exception('Plain backup creation failed: $e');
    }
  }

  Future<void> restoreFromBackup(String backupJson, {bool clearExisting = true}) async {
    try {
      final Map<String, dynamic> backupData = jsonDecode(backupJson);
      
      if (!_validateBackupFormat(backupData)) {
        throw Exception('Invalid backup format');
      }

      if (clearExisting) {
        await _clearAllPasswords();
      }

      final passwordsList = backupData['passwords'] as List;
      for (final passwordMap in passwordsList) {
        final password = PasswordEntry(
          id: passwordMap['id'],
          title: passwordMap['title'],
          username: passwordMap['username'],
          password: passwordMap['password'],
          url: passwordMap['url'] ?? '',
          notes: passwordMap['notes'] ?? '',
          createdAt: DateTime.fromMillisecondsSinceEpoch(passwordMap['createdAt']),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(passwordMap['updatedAt']),
          isCompromised: passwordMap['isCompromised'] == true,
        );
        
        await StorageService.instance.savePassword(password);
      }
    } catch (e) {
      throw Exception('Backup restoration failed: $e');
    }
  }

  Future<void> exportBackup({bool encrypted = true}) async {
    try {
      final backupData = encrypted 
        ? await createEncryptedBackup()
        : await createPlainBackup();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final encryptionSuffix = encrypted ? '_encrypted' : '_plain';
      final fileName = 'hiddenPW_backup$encryptionSuffix\_$timestamp.json';
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(backupData);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'HiddenPW Backup File',
        subject: 'Password Manager Backup',
      );
    } catch (e) {
      throw Exception('Backup export failed: $e');
    }
  }

  Future<void> importBackup(String fileContent, {bool clearExisting = true}) async {
    try {
      await restoreFromBackup(fileContent, clearExisting: clearExisting);
    } catch (e) {
      throw Exception('Backup import failed: $e');
    }
  }

  Future<void> createAutoBackup() async {
    try {
      final backupData = await createEncryptedBackup();
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFile = File('${backupDir.path}/auto_backup_$timestamp.json');
      
      await backupFile.writeAsString(backupData);
      
      await _cleanupOldBackups(backupDir);
    } catch (e) {
      throw Exception('Auto backup failed: $e');
    }
  }

  Future<List<File>> getAutoBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final backupFiles = backupDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.contains('auto_backup_'))
          .toList();
      
      backupFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      
      return backupFiles;
    } catch (e) {
      return [];
    }
  }

  Future<void> restoreFromAutoBackup(File backupFile) async {
    try {
      final backupContent = await backupFile.readAsString();
      await restoreFromBackup(backupContent);
    } catch (e) {
      throw Exception('Auto backup restoration failed: $e');
    }
  }

  bool _validateBackupFormat(Map<String, dynamic> backupData) {
    return backupData.containsKey('version') &&
           backupData.containsKey('timestamp') &&
           backupData.containsKey('app') &&
           backupData.containsKey('passwords') &&
           backupData['app'] == 'HiddenPW';
  }

  Future<void> _clearAllPasswords() async {
    final passwords = await StorageService.instance.getAllPasswords();
    for (final password in passwords) {
      await StorageService.instance.deletePassword(password.id);
    }
  }

  Future<void> _cleanupOldBackups(Directory backupDir, {int keepCount = 5}) async {
    try {
      final backupFiles = backupDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.contains('auto_backup_'))
          .toList();
      
      if (backupFiles.length <= keepCount) return;
      
      backupFiles.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      
      final filesToDelete = backupFiles.take(backupFiles.length - keepCount);
      for (final file in filesToDelete) {
        await file.delete();
      }
    } catch (e) {
      
    }
  }

  Future<Map<String, dynamic>> getBackupStats() async {
    try {
      final autoBackups = await getAutoBackups();
      final lastBackup = autoBackups.isNotEmpty ? autoBackups.first : null;
      
      return {
        'autoBackupCount': autoBackups.length,
        'lastBackupDate': lastBackup?.statSync().modified,
        'lastBackupSize': lastBackup?.lengthSync(),
      };
    } catch (e) {
      return {
        'autoBackupCount': 0,
        'lastBackupDate': null,
        'lastBackupSize': null,
      };
    }
  }
}