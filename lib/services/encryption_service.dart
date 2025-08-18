import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  late Encrypter _encrypter;
  late IV _iv;
  bool _isInitialized = false;

  void initializeWithMasterPassword(String masterPassword) {
    final key = _deriveKeyFromPassword(masterPassword);
    _encrypter = Encrypter(AES(key));
    _iv = IV.fromSecureRandom(16);
    _isInitialized = true;
  }

  Key _deriveKeyFromPassword(String password) {
    const iterations = 10000;
    final salt = utf8.encode('HiddenPW-Salt'); 
    
    var hmac = Hmac(sha256, utf8.encode(password));
    var digest = hmac.convert(salt);
    
    for (int i = 0; i < iterations; i++) {
      hmac = Hmac(sha256, digest.bytes);
      digest = hmac.convert(salt);
    }
    
    return Key(Uint8List.fromList(digest.bytes));
  }

  String encryptData(String plainText) {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptData(String encryptedData) {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    final parts = encryptedData.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid encrypted data format');
    }
    
    try {
      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  String hashPassword(String password) {
    final salt = 'HiddenPW-Password-Salt';
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateSecureHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyHash(String data, String hash) {
    final dataHash = generateSecureHash(data);
    return dataHash == hash;
  }

  String generateSalt([int length = 32]) {
    final iv = IV.fromSecureRandom(length);
    return iv.base64;
  }

  String encryptWithIV(String plainText, String ivString) {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      final iv = IV.fromBase64(ivString);
      final encrypted = _encrypter.encrypt(plainText, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption with IV failed: $e');
    }
  }

  String decryptWithIV(String encryptedData, String ivString) {
    if (!_isInitialized) {
      throw Exception('Encryption service not initialized');
    }
    
    try {
      final iv = IV.fromBase64(ivString);
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption with IV failed: $e');
    }
  }
  bool get isInitialized => _isInitialized;

  void reset() {
    _isInitialized = false;
  }
}