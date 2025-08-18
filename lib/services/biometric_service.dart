import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  static BiometricService get instance => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'HiddenPW\'ye erişmek için kimliğinizi doğrulayın',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } on PlatformException catch (e) {
      print('Biometric authentication error: ${e.message}');
      return false;
    }
  }
}