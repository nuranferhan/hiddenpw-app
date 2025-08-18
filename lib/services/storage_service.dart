import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_entry.dart';
import 'encryption_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static StorageService get instance => _instance;
  StorageService._internal();

  Database? _database;
  final _secureStorage = const FlutterSecureStorage();
  final _encryptionService = EncryptionService();

  Future<void> init() async {
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, 'hiddenPW.db');

      _database = sqlite3.open(path);
      _createDatabase();
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  void _createDatabase() {
    _database?.execute('''
      CREATE TABLE IF NOT EXISTS passwords (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        url TEXT,
        notes TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isCompromised INTEGER DEFAULT 0
      )
    ''');
  }

  Future<bool> isMasterPasswordSet() async {
    final hash = await _secureStorage.read(key: 'master_password_hash');
    return hash != null;
  }

  Future<void> setMasterPassword(String password) async {
    final hash = _encryptionService.hashPassword(password);
    await _secureStorage.write(key: 'master_password_hash', value: hash);
    _encryptionService.initializeWithMasterPassword(password);
  }

  Future<bool> verifyMasterPassword(String password) async {
    final storedHash = await _secureStorage.read(key: 'master_password_hash');
    final inputHash = _encryptionService.hashPassword(password);
    
    if (storedHash == inputHash) {
      _encryptionService.initializeWithMasterPassword(password);
      return true;
    }
    return false;
  }

  Future<List<PasswordEntry>> getAllPasswords() async {
    if (_database == null) return [];
    
    try {
      final ResultSet results = _database!.select('SELECT * FROM passwords ORDER BY updatedAt DESC');
      
      return results.map((row) {
        final Map<String, dynamic> map = {
          'id': row['id'],
          'title': row['title'],
          'username': row['username'],
          'password': _encryptionService.decryptData(row['password']),
          'url': row['url'],
          'notes': row['notes'],
          'createdAt': row['createdAt'],
          'updatedAt': row['updatedAt'],
          'isCompromised': row['isCompromised'],
        };
        return PasswordEntry.fromJson(map);
      }).toList();
    } catch (e) {
      print('Error getting passwords: $e');
      return [];
    }
  }

  Future<void> savePassword(PasswordEntry entry) async {
    if (_database == null) return;

    try {
      final encryptedPassword = _encryptionService.encryptData(entry.password);
      
      _database!.execute('''
        INSERT OR REPLACE INTO passwords 
        (id, title, username, password, url, notes, createdAt, updatedAt, isCompromised) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
        entry.id,
        entry.title,
        entry.username,
        encryptedPassword,
        entry.url,
        entry.notes,
        entry.createdAt.millisecondsSinceEpoch,
        entry.updatedAt.millisecondsSinceEpoch,
        entry.isCompromised ? 1 : 0,
      ]);
    } catch (e) {
      print('Error saving password: $e');
      rethrow;
    }
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    if (_database == null) return;

    try {
      final encryptedPassword = _encryptionService.encryptData(entry.password);
      
      _database!.execute('''
        UPDATE passwords 
        SET title = ?, username = ?, password = ?, url = ?, notes = ?, 
            updatedAt = ?, isCompromised = ?
        WHERE id = ?
      ''', [
        entry.title,
        entry.username,
        encryptedPassword,
        entry.url,
        entry.notes,
        entry.updatedAt.millisecondsSinceEpoch,
        entry.isCompromised ? 1 : 0,
        entry.id,
      ]);
    } catch (e) {
      print('Error updating password: $e');
      rethrow;
    }
  }

  Future<void> deletePassword(String id) async {
    if (_database == null) return;

    try {
      _database!.execute('DELETE FROM passwords WHERE id = ?', [id]);
    } catch (e) {
      print('Error deleting password: $e');
      rethrow;
    }
  }

  Future<String> exportData() async {
    final passwords = await getAllPasswords();
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'passwords': passwords.map((p) => p.toJson()).toList(),
    };
    return jsonEncode(exportData);
  }

  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      final passwordsList = data['passwords'] as List;
      
      for (final passwordMap in passwordsList) {
        final entry = PasswordEntry.fromJson(passwordMap);
        await savePassword(entry);
      }
    } catch (e) {
      print('Error importing data: $e');
      rethrow;
    }
  }

  void dispose() {
    _database?.dispose();
  }
}