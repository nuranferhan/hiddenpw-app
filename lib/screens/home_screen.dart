import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../services/breach_checker_service.dart';
import '../widgets/password_card.dart';
import 'add_password_screen.dart';
import 'password_generator_screen.dart';
import 'settings_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PasswordEntry> _passwords = [];
  List<PasswordEntry> _filteredPasswords = [];
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingBreaches = false;

  @override
void initState() {
  super.initState();
  _loadPasswords();
  _searchController.addListener(_filterPasswords);
  
  Timer.periodic(Duration(seconds: 5), (timer) {
    print('Auto refreshing passwords...');
    _loadPasswords();
    if (timer.tick > 6) {
      timer.cancel();
    }
  });
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);
    try {
      final passwords = await StorageService.instance.getAllPasswords();
      setState(() {
        _passwords = passwords;
        _filteredPasswords = passwords;
      });
    } catch (e) {
      _showSnackBar('Şifreler yüklenirken hata oluştu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPasswords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPasswords = _passwords.where((password) {
        return password.title.toLowerCase().contains(query) ||
            password.username.toLowerCase().contains(query) ||
            password.url.toLowerCase().contains(query);
      }).toList();
    });
  }

  int _calculatePasswordStrength(String password) {
    int score = 0;
    
    if (password.length >= 8) score += 25;
    if (password.length >= 12) score += 25;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 20;
    
    return score.clamp(0, 100);
  }

  bool _isPasswordWeak(String password) {
    return _calculatePasswordStrength(password) < 60;
  }

  Future<void> _checkForBreaches() async {
    setState(() => _isCheckingBreaches = true);
    try {
      final passwords = _passwords.map((p) => p.password).toList();
      final compromisedPasswords = await BreachCheckerService.instance.checkMultiplePasswords(passwords);

      if (compromisedPasswords.isNotEmpty) {
        for (final password in _passwords) {
          if (compromisedPasswords.contains(password.password) && !password.isCompromised) {
            final updatedPassword = password.copyWith(isCompromised: true);
            await StorageService.instance.updatePassword(updatedPassword);
          }
        }
        await _loadPasswords();
        _showSnackBar('${compromisedPasswords.length} şifre güvenlik ihlali tespit edildi!');
      } else {
        _showSnackBar('Sizin için buradayız!');
      }
    } catch (e) {
      _showSnackBar('Güvenlik kontrolü yapılırken hata oluştu');
    } finally {
      setState(() => _isCheckingBreaches = false);
    }
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
    
    int compromisedCount = _passwords.where((p) => p.isCompromised).length;
    int weakPasswordCount = _passwords.where((p) => _isPasswordWeak(p.password) && !p.isCompromised).length;
    int totalRiskyPasswords = compromisedCount + weakPasswordCount;
    int safePasswordCount = _passwords.length - totalRiskyPasswords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HiddenPW'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(_isCheckingBreaches ? Icons.refresh : Icons.security),
            onPressed: _isCheckingBreaches ? null : _checkForBreaches,
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PasswordGeneratorScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Şifre ara…',
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                filled: true,
                fillColor: colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Statistics
          if (_passwords.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Toplam', 
                    _passwords.length.toString(), 
                    Icons.lock,
                    color: colorScheme.primary,
                  ),
                  _buildStatItem(
                    'Güvenlik İhlali', 
                    totalRiskyPasswords.toString(), 
                    Icons.warning,
                    color: totalRiskyPasswords > 0 ? Colors.red : colorScheme.onSurface.withOpacity(0.5),
                  ),
                  _buildStatItem(
                    'Güvenli', 
                    safePasswordCount.toString(), 
                    Icons.check_circle,
                    color: safePasswordCount > 0 ? Colors.green : colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPasswords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isNotEmpty 
                                ? Icons.search_off 
                                : Icons.lock_outline,
                              size: 64,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Arama sonucu bulunamadı'
                                  : 'Henüz kayıtlı şifre yok',
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            if (_searchController.text.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'İlk şifrenizi eklemek için + butonuna basın',
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPasswords,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredPasswords.length,
                          itemBuilder: (context, index) {
                            return PasswordCard(
                              passwordEntry: _filteredPasswords[index],
                              onRefresh: _loadPasswords,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPasswordScreen()),
          );
          if (result == true) {
            _loadPasswords();
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    final theme = Theme.of(context);
    final defaultColor = color ?? theme.colorScheme.primary;
    
    return Column(
      children: [
        Icon(icon, color: defaultColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: defaultColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
