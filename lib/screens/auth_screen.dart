import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/biometric_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isFirstTime;
  
  const AuthScreen({super.key, this.isFirstTime = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService.instance.isBiometricAvailable();
    setState(() => _biometricAvailable = available);
  }

  Future<void> _authenticate() async {
    if (_passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (widget.isFirstTime) {
        if (_passwordController.text != _confirmPasswordController.text) {
          _showSnackBar('Şifreler eşleşmiyor!');
          return;
        }
        if (_passwordController.text.length < 8) {
          _showSnackBar('Ana şifre en az 8 karakter olmalıdır!');
          return;
        }
        await StorageService.instance.setMasterPassword(_passwordController.text);
        _navigateToHome();
      } else {
        final isValid = await StorageService.instance.verifyMasterPassword(_passwordController.text);
        if (isValid) {
          _navigateToHome();
        } else {
          _showSnackBar('Hatalı ana şifre!');
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final isAuthenticated = await BiometricService.instance.authenticateWithBiometrics();
    if (isAuthenticated) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  widget.isFirstTime ? 'Ana Şifre Oluştur' : 'HiddenPW',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                if (widget.isFirstTime) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Ana Şifre Tekrar',
                      labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticate,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(widget.isFirstTime ? 'Oluştur' : 'Giriş Yap'),
                  ),
                ),
                if (!widget.isFirstTime && _biometricAvailable) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _authenticateWithBiometric,
                    icon: Icon(Icons.fingerprint, color: colorScheme.primary),
                    label: Text(
                      'Biyometrik ile Giriş',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}