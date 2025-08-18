import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class BreachCheckerService {
  static final BreachCheckerService _instance = BreachCheckerService._internal();
  static BreachCheckerService get instance => _instance;
  BreachCheckerService._internal();

  Future<bool> isPasswordCompromised(String password) async {
    try {
      final sha1Hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
      final prefix = sha1Hash.substring(0, 5);
      final suffix = sha1Hash.substring(5);

      final response = await http.get(
        Uri.parse('https://api.pwnedpasswords.com/range/$prefix'),
        headers: {'User-Agent': 'HiddenPW-App'},
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines) {
          final parts = line.split(':');
          if (parts[0] == suffix) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> checkMultiplePasswords(List<String> passwords) async {
    final compromisedPasswords = <String>[];
    
    for (final password in passwords) {
      if (await isPasswordCompromised(password)) {
        compromisedPasswords.add(password);
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return compromisedPasswords;
  }
}

