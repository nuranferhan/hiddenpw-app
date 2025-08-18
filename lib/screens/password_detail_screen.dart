import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../services/breach_checker_service.dart';
import '../widgets/security_indicator.dart';
import 'add_password_screen.dart';

class PasswordDetailScreen extends StatefulWidget {
  final PasswordEntry passwordEntry;

  const PasswordDetailScreen({super.key, required this.passwordEntry});

  @override
  State<PasswordDetailScreen> createState() => _PasswordDetailScreenState();
}

class _PasswordDetailScreenState extends State<PasswordDetailScreen> {
  late PasswordEntry _passwordEntry;
  bool _isPasswordVisible = false;
  bool _isCheckingBreach = false;

  @override
  void initState() {
    super.initState();
    _passwordEntry = widget.passwordEntry;
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

  String _getPasswordStatus() {
    if (_passwordEntry.isCompromised) {
      return 'Güvenlik İhlali';
    }
    
    int strength = _calculatePasswordStrength(_passwordEntry.password);
    
    if (strength >= 70) {
      return 'Güvenli';
    } else if (strength >= 40) {
      return 'İyileştirilebilir';
    } else {
      return 'Tehlikeli';
    }
  }

  Color _getStatusColor() {
    if (_passwordEntry.isCompromised) {
      return Colors.red;
    }
    
    int strength = _calculatePasswordStrength(_passwordEntry.password);
    
    if (strength >= 70) {
      return Colors.green;
    } else if (strength >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label panoya kopyalandı')),
      );
    }
  }

  Future<void> _checkPasswordBreach() async {
    setState(() => _isCheckingBreach = true);
    try {
      final isCompromised = await BreachCheckerService.instance
          .isPasswordCompromised(_passwordEntry.password);

      if (isCompromised != _passwordEntry.isCompromised) {
        final updatedEntry = _passwordEntry.copyWith(isCompromised: isCompromised);
        await StorageService.instance.updatePassword(updatedEntry);
        setState(() => _passwordEntry = updatedEntry);
      }

      final message = isCompromised
          ? 'Bu şifre güvenlik ihlalinde tespit edilmiş!'
          : 'Şifre güvenli görünüyor!';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isCompromised ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güvenlik kontrolü yapılamadı')),
        );
      }
    } finally {
      setState(() => _isCheckingBreach = false);
    }
  }

  Future<void> _editPassword() async {
  print('Navigating to edit screen for: ${_passwordEntry.title}');
  
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddPasswordScreen(passwordEntry: _passwordEntry),
    ),
  );

  print('Edit screen returned with result: $result');

  if (result != null) {
    print('Refreshing password entry after edit');
    
    final passwords = await StorageService.instance.getAllPasswords();
    final updatedEntry = passwords.firstWhere(
      (p) => p.id == _passwordEntry.id,
      orElse: () => _passwordEntry,
    );
    
    setState(() => _passwordEntry = updatedEntry);
    
    print('Password entry updated: ${updatedEntry.title}');
    
    Navigator.pop(context, true);
  }
}

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifreyi Sil'),
          content: const Text(
            'Bu şifreyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deletePassword();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePassword() async {
    try {
      await StorageService.instance.deletePassword(_passwordEntry.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifre silinirken hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final cardColor = isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.grey : Colors.grey[600];
    final borderColor = isDarkMode 
        ? Colors.grey.withOpacity(0.3) 
        : Colors.grey.withOpacity(0.3);
    
    int passwordStrength = _calculatePasswordStrength(_passwordEntry.password);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_passwordEntry.title),
        actions: [
          IconButton(
            icon: _isCheckingBreach
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.security),
            onPressed: _isCheckingBreach ? null : _checkPasswordBreach,
            tooltip: 'Güvenlik İhlali Kontrolü',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPassword,
            tooltip: 'Düzenle',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sil', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Güvenlik durumuna göre mesajlar
            if (_passwordEntry.isCompromised)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu şifre güvenlik ihlalinde tespit edilmiş. Değiştirmeniz önerilir.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else if (passwordStrength >= 70)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Harika! Bu şifre güvenli.',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              )
            else if (passwordStrength >= 40)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu şifrenin iyileştirilebilir yanları var. Şifre güvenli hale getirilebilir.',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu şifre güvenlik açısından zayıf. Daha güçlü bir şifre kullanmanız önerilir.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            _buildDetailCard(
              'Başlık',
              _passwordEntry.title,
              Icons.title,
              cardColor,
              primaryTextColor,
              secondaryTextColor!,
              borderColor,
              onTap: () => _copyToClipboard(_passwordEntry.title, 'Başlık'),
            ),

            const SizedBox(height: 16),

            _buildDetailCard(
              'Kullanıcı Adı',
              _passwordEntry.username,
              Icons.person,
              cardColor,
              primaryTextColor,
              secondaryTextColor,
              borderColor,
              onTap: () => _copyToClipboard(_passwordEntry.username, 'Kullanıcı adı'),
            ),

            const SizedBox(height: 16),

            _buildPasswordCard(cardColor, primaryTextColor, secondaryTextColor, borderColor),

            const SizedBox(height: 16),

            SecurityIndicator(password: _passwordEntry.password),

            if (_passwordEntry.url.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                'Website',
                _passwordEntry.url,
                Icons.link,
                cardColor,
                primaryTextColor,
                secondaryTextColor,
                borderColor,
                onTap: () => _copyToClipboard(_passwordEntry.url, 'Website URL'),
              ),
            ],

            if (_passwordEntry.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                'Notlar',
                _passwordEntry.notes,
                Icons.note,
                cardColor,
                primaryTextColor,
                secondaryTextColor,
                borderColor,
                onTap: () => _copyToClipboard(_passwordEntry.notes, 'Notlar'),
                maxLines: null,
              ),
            ],

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bilgiler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Oluşturulma', _formatDate(_passwordEntry.createdAt), primaryTextColor, secondaryTextColor),
                  const SizedBox(height: 8),
                  _buildInfoRow('Son Güncelleme', _formatDate(_passwordEntry.updatedAt), primaryTextColor, secondaryTextColor),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Durum',
                    _getPasswordStatus(),
                    primaryTextColor,
                    secondaryTextColor,
                    color: _getStatusColor(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    String label,
    String value,
    IconData icon,
    Color cardColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color borderColor, {
    VoidCallback? onTap,
    int? maxLines = 1,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryTextColor,
                    ),
                    maxLines: maxLines,
                    overflow: maxLines == null ? null : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.copy,
                color: secondaryTextColor.withOpacity(0.7),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard(Color cardColor, Color primaryTextColor, Color secondaryTextColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Şifre',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPasswordVisible
                      ? _passwordEntry.password
                      : '•' * _passwordEntry.password.length,
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryTextColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: secondaryTextColor.withOpacity(0.7),
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            tooltip: _isPasswordVisible ? 'Gizle' : 'Göster',
          ),
          IconButton(
            icon: Icon(
              Icons.copy,
              color: secondaryTextColor.withOpacity(0.7),
            ),
            onPressed: () => _copyToClipboard(_passwordEntry.password, 'Şifre'),
            tooltip: 'Kopyala',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color primaryTextColor, Color secondaryTextColor, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: secondaryTextColor),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}