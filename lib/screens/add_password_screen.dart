import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../services/breach_checker_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/security_indicator.dart';
import '../utils/helpers.dart';
import 'password_generator_screen.dart';

class AddPasswordScreen extends StatefulWidget {
  final PasswordEntry? passwordEntry;

  const AddPasswordScreen({super.key, this.passwordEntry});

  @override
  State<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isCheckingBreach = false;
  bool _isCompromised = false;
  String? _lastCheckedPassword; // Son kontrol edilen şifreyi takip etmek için

  @override
  void initState() {
    super.initState();
    if (widget.passwordEntry != null) {
      _loadExistingPassword();
    }
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadExistingPassword() {
    final entry = widget.passwordEntry!;
    _titleController.text = entry.title;
    _usernameController.text = entry.username;
    _passwordController.text = entry.password;
    _urlController.text = entry.url;
    _notesController.text = entry.notes;
    _isCompromised = entry.isCompromised;
    _lastCheckedPassword = entry.password;
  }

  void _onPasswordChanged() {
    if (_passwordController.text != _lastCheckedPassword) {
      setState(() {
        if (widget.passwordEntry == null || _passwordController.text != widget.passwordEntry!.password) {
          _isCompromised = false; // Yeni şifre için durumu sıfırla
        }
      });
    }
    setState(() {}); 
  }

  Future<void> _checkPasswordBreach() async {
    final currentPassword = _passwordController.text.trim();
    
    if (currentPassword.isEmpty) {
      _showSnackBar('Lütfen önce bir şifre girin', isError: true);
      return;
    }

    if (_lastCheckedPassword == currentPassword) {
      if (_isCompromised) {
        _showSnackBar('Bu şifre daha önce güvenlik ihlalinde tespit edilmiş!', isError: true);
      } else {
        _showSnackBar('Bu şifre zaten kontrol edildi ve güvenli görünüyor!');
      }
      return;
    }

    setState(() => _isCheckingBreach = true);
    
    try {
      final isCompromised = await BreachCheckerService.instance.isPasswordCompromised(currentPassword);
      
      setState(() {
        _isCompromised = isCompromised;
        _lastCheckedPassword = currentPassword;
      });
      
      if (mounted) {
        if (isCompromised) {
          _showSnackBar('Bu şifre daha önce güvenlik ihlalinde tespit edilmiş! Değiştirmeniz önerilir.', isError: true);
        } else {
          _showSnackBar('Şifre güvenli görünüyor!');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Güvenlik kontrolü yapılamadı. İnternet bağlantınızı kontrol edin.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingBreach = false);
      }
    }
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final entry = PasswordEntry(
        id: widget.passwordEntry?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        url: _urlController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: widget.passwordEntry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isCompromised: _isCompromised,
      );

      if (widget.passwordEntry != null) {
        await StorageService.instance.updatePassword(entry);
        if (mounted) {
          _showSnackBar('Şifre başarıyla güncellendi!');
        }
      } else {
        await StorageService.instance.savePassword(entry);
        if (mounted) {
          _showSnackBar('Şifre başarıyla kaydedildi!');
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Şifre kaydedilirken hata oluştu: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generatePassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordGeneratorScreen()),
    );

    if (result != null && result is String && mounted) {
      setState(() {
        _passwordController.text = result;
        _isCompromised = false; // Reset compromise status for new password
        _lastCheckedPassword = null; // Yeni şifre henüz kontrol edilmedi
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.passwordEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Şifreyi Düzenle' : 'Yeni Şifre Ekle'),
        actions: [
          if (_passwordController.text.isNotEmpty)
            IconButton(
              icon: _isCheckingBreach 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Icon(
                    Icons.security,
                    color: _isCompromised ? Colors.red : null,
                  ),
              onPressed: _isCheckingBreach ? null : _checkPasswordBreach,
              tooltip: 'Güvenlik İhlali Kontrolü',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (_isCompromised)
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
                    const Expanded(
                      child: Text(
                        'Bu şifre güvenlik ihlalinde tespit edilmiş. Değiştirmeniz önerilir.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () => setState(() => _isCompromised = false),
                      tooltip: 'Uyarıyı kapat',
                    ),
                  ],
                ),
              ),

            CustomTextField(
              controller: _titleController,
              label: 'Başlık',
              hint: 'örn: Gmail, Facebook',
              icon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Başlık gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _usernameController,
              label: 'Kullanıcı Adı / E-posta',
              hint: 'kullanici@example.com',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kullanıcı adı gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _passwordController,
              label: 'Şifre',
              hint: 'Güçlü bir şifre girin',
              icon: Icons.lock,
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre gerekli';
                }
                if (value.length < 4) {
                  return 'Şifre en az 4 karakter olmalı';
                }
                return null;
              },
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: _generatePassword,
                    tooltip: 'Şifre Üret',
                  ),
                  IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ],
              ),
            ),
            
            Container(
              height: _passwordController.text.isNotEmpty ? null : 0,
              margin: const EdgeInsets.only(top: 8),
              child: _passwordController.text.isNotEmpty
                  ? SecurityIndicator(password: _passwordController.text)
                  : const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _urlController,
              label: 'Website URL (İsteğe bağlı)',
              hint: 'https://example.com',
              icon: Icons.link,
            ),
            
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _notesController,
              label: 'Notlar (İsteğe bağlı)',
              hint: 'Ek bilgiler...',
              icon: Icons.note,
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePassword,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? 'Güncelle' : 'Kaydet'),
              ),
            ),
            
            if (isEditing) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _showDeleteDialog(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Sil'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifreyi Sil'),
          content: const Text('Bu şifreyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
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
    setState(() => _isLoading = true);
    try {
      await StorageService.instance.deletePassword(widget.passwordEntry!.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Şifre silinirken hata oluştu: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}