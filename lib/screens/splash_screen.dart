import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(seconds: 4)); // 2 saniyeden 4 saniyeye çıkarıldı
        
    if (!mounted) return;
        
    final isMasterPasswordSet = await StorageService.instance.isMasterPasswordSet();
        
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isMasterPasswordSet
           ? const AuthScreen()
           : const AuthScreen(isFirstTime: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 24),
              Text(
                'HiddenPW',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Güvenli Şifre Yöneticisi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}