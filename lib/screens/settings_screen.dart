import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../services/biometric_service.dart';
import '../services/theme_service.dart';
import '../models/security_settings.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _autoLockEnabled = true;
  int _autoLockMinutes = 5;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {

    setState(() {
      _biometricEnabled = false; // Load from storage
      _autoLockEnabled = true;   // Load from storage
      _autoLockMinutes = 5;      // Load from storage
    });
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    try {
      final jsonData = await StorageService.instance.exportData();
      final fileName = 'hiddenPW_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      final directory = Directory.systemTemp;
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonData);
      
      await Share.shareXFiles([XFile(file.path)], text: 'HiddenPW Yedek Dosyası');
      
      _showSnackBar('Veriler başarıyla dışa aktarıldı');
    } catch (e) {
      _showSnackBar('Dışa aktarma hatası: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonData = await file.readAsString();
        
        await _showImportConfirmDialog(jsonData);
      }
    } catch (e) {
      _showSnackBar('İçe aktarma hatası: $e', isError: true);
    }
  }

  Future<void> _showImportConfirmDialog(String jsonData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri İçe Aktar'),
        content: const Text(
          'Bu işlem mevcut tüm şifrelerinizi siler ve yedek dosyasındaki '
          'verilerle değiştirir. Devam etmek istediğinizden emin misiniz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('İçe Aktar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await StorageService.instance.importData(jsonData);
        _showSnackBar('Veriler başarıyla içe aktarıldı');
      } catch (e) {
        _showSnackBar('İçe aktarma hatası: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeMasterPassword() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _MasterPasswordChangeDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        final currentPassword = result[0];
        final newPassword = result[1];
        
        final isCurrentValid = await StorageService.instance.verifyMasterPassword(currentPassword);
        if (!isCurrentValid) {
          _showSnackBar('Mevcut ana şifre hatalı!', isError: true);
          return;
        }

        await StorageService.instance.setMasterPassword(newPassword);
        _showSnackBar('Ana şifre başarıyla değiştirildi');
      } catch (e) {
        _showSnackBar('Ana şifre değiştirme hatası: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Verileri Sil'),
        content: const Text(
          'Bu işlem tüm şifrelerinizi ve ayarlarınızı kalıcı olarak siler. '
          'Bu işlem geri alınamaz. Devam etmek istediğinizden emin misiniz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final passwords = await StorageService.instance.getAllPasswords();
        for (final password in passwords) {
          await StorageService.instance.deletePassword(password.id);
        }
        
        _showSnackBar('Tüm veriler silindi');
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        _showSnackBar('Veri silme hatası: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Sistem'),
              subtitle: const Text('Cihaz ayarını takip et'),
              value: ThemeMode.system,
              groupValue: ThemeService.instance.themeMode,
              onChanged: (value) {
                ThemeService.instance.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Açık Tema'),
              value: ThemeMode.light,
              groupValue: ThemeService.instance.themeMode,
              onChanged: (value) {
                ThemeService.instance.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Koyu Tema'),
              value: ThemeMode.dark,
              groupValue: ThemeService.instance.themeMode,
              onChanged: (value) {
                ThemeService.instance.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeText() {
    switch (ThemeService.instance.themeMode) {
      case ThemeMode.system:
        return 'Sistem';
      case ThemeMode.light:
        return 'Açık Tema';
      case ThemeMode.dark:
        return 'Koyu Tema';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ayarlar'),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
            
                    _buildSectionHeader('Görünüm'),
                    _buildSettingsTile(
                      title: 'Tema',
                      subtitle: _getThemeText(),
                      icon: ThemeService.instance.isDarkMode 
                          ? Icons.dark_mode 
                          : Icons.light_mode,
                      onTap: _showThemeDialog,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('Güvenlik'),
                    _buildSettingsTile(
                      title: 'Ana Şifre Değiştir',
                      subtitle: 'Ana şifrenizi değiştirin',
                      icon: Icons.key,
                      onTap: _changeMasterPassword,
                    ),
                    _buildSwitchTile(
                      title: 'Biyometrik Kilit',
                      subtitle: 'Parmak izi veya yüz tanıma ile giriş',
                      icon: Icons.fingerprint,
                      value: _biometricEnabled,
                      onChanged: (value) async {
                        if (value) {
                          final available = await BiometricService.instance.isBiometricAvailable();
                          if (!available) {
                            _showSnackBar('Biyometrik kimlik doğrulama bu cihazda desteklenmiyor', isError: true);
                            return;
                          }
                        }
                        setState(() => _biometricEnabled = value);
                      },
                    ),
                    _buildSwitchTile(
                      title: 'Otomatik Kilit',
                      subtitle: 'Belirli süre sonra otomatik kilitle',
                      icon: Icons.lock_clock,
                      value: _autoLockEnabled,
                      onChanged: (value) => setState(() => _autoLockEnabled = value),
                    ),
                    if (_autoLockEnabled)
                      _buildSettingsTile(
                        title: 'Otomatik Kilit Süresi',
                        subtitle: '$_autoLockMinutes dakika',
                        icon: Icons.timer,
                        onTap: () => _showAutoLockTimeDialog(),
                      ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('Yedekleme'),
                    _buildSettingsTile(
                      title: 'Verileri Dışa Aktar',
                      subtitle: 'Şifrelerinizi JSON dosyasına aktar',
                      icon: Icons.file_upload,
                      onTap: _exportData,
                    ),
                    _buildSettingsTile(
                      title: 'Verileri İçe Aktar',
                      subtitle: 'JSON dosyasından şifreleri içe aktar',
                      icon: Icons.file_download,
                      onTap: _importData,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('Uygulama'),
                    _buildSettingsTile(
                      title: 'Hakkında',
                      subtitle: 'HiddenPW v1.0.0',
                      icon: Icons.info,
                      onTap: () => _showAboutDialog(),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('Tehlikeli Bölge', color: Colors.red),
                    _buildSettingsTile(
                      title: 'Tüm Verileri Sil',
                      subtitle: 'Tüm şifreler ve ayarlar silinir',
                      icon: Icons.delete_forever,
                      onTap: _deleteAllData,
                      textColor: Colors.red,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? Colors.grey[400]),
        title: Text(
          title,
          style: TextStyle(color: textColor ?? Theme.of(context).textTheme.titleMedium?.color),
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        trailing: Icon(
          Icons.chevron_right, 
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.grey[400]),
        title: Text(
          title, 
          style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showAutoLockTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Otomatik Kilit Süresi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('1 dakika'),
              value: 1,
              groupValue: _autoLockMinutes,
              onChanged: (value) {
                setState(() => _autoLockMinutes = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('5 dakika'),
              value: 5,
              groupValue: _autoLockMinutes,
              onChanged: (value) {
                setState(() => _autoLockMinutes = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('10 dakika'),
              value: 10,
              groupValue: _autoLockMinutes,
              onChanged: (value) {
                setState(() => _autoLockMinutes = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('30 dakika'),
              value: 30,
              groupValue: _autoLockMinutes,
              onChanged: (value) {
                setState(() => _autoLockMinutes = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'HiddenPW',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.security, 
        size: 64, 
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text('Güvenli offline şifre yöneticisi.'),
        const SizedBox(height: 16),
        const Text('Özellikler:'),
        const Text('• AES-256 şifreleme'),
        const Text('• Biyometrik doğrulama'),
        const Text('• Güvenlik ihlali kontrolü'),
        const Text('• Güçlü parola üretici'),
        const Text('• Tamamen offline'),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Nuran Ferhan tarafından geliştirildi.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
        const Center(
          child: Text(
            'Copyright © 2025 Tüm hakları saklıdır.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _MasterPasswordChangeDialog extends StatefulWidget {
  @override
  State<_MasterPasswordChangeDialog> createState() => _MasterPasswordChangeDialogState();
}

class _MasterPasswordChangeDialogState extends State<_MasterPasswordChangeDialog> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ana Şifre Değiştir'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mevcut Ana Şifre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mevcut ana şifre gerekli';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Ana Şifre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Yeni ana şifre gerekli';
                }
                if (value.length < 8) {
                  return 'Ana şifre en az 8 karakter olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Ana Şifre Tekrar',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != _newPasswordController.text) {
                  return 'Şifreler eşleşmiyor';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, [
                _currentPasswordController.text,
                _newPasswordController.text,
              ]);
            }
          },
          child: const Text('Değiştir'),
        ),
      ],
    );
  }
}