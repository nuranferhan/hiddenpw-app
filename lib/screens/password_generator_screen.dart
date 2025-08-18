import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../widgets/security_indicator.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = '';
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _excludeSimilar = false;
  bool _excludeAmbiguous = false;

  final String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  final String _numbers = '0123456789';
  final String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  final String _similar = 'il1Lo0O';
  final String _ambiguous = '{}[]()/\\\'"`~,;.<>';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    if (!_includeUppercase && !_includeLowercase && !_includeNumbers && !_includeSymbols) {
      setState(() => _generatedPassword = '');
      return;
    }

    String charset = '';
    
    if (_includeUppercase) charset += _uppercase;
    if (_includeLowercase) charset += _lowercase;
    if (_includeNumbers) charset += _numbers;
    if (_includeSymbols) charset += _symbols;

    if (_excludeSimilar) {
      for (String char in _similar.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }

    if (_excludeAmbiguous) {
      for (String char in _ambiguous.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }

    if (charset.isEmpty) {
      setState(() => _generatedPassword = '');
      return;
    }

    final random = Random.secure();
    String password = '';

    if (_includeUppercase && _uppercase.isNotEmpty) {
      String availableUpper = _uppercase;
      if (_excludeSimilar) {
        for (String char in _similar.split('')) {
          availableUpper = availableUpper.replaceAll(char, '');
        }
      }
      if (availableUpper.isNotEmpty) {
        password += availableUpper[random.nextInt(availableUpper.length)];
      }
    }

    if (_includeLowercase && _lowercase.isNotEmpty) {
      String availableLower = _lowercase;
      if (_excludeSimilar) {
        for (String char in _similar.split('')) {
          availableLower = availableLower.replaceAll(char, '');
        }
      }
      if (availableLower.isNotEmpty) {
        password += availableLower[random.nextInt(availableLower.length)];
      }
    }

    if (_includeNumbers && _numbers.isNotEmpty) {
      String availableNumbers = _numbers;
      if (_excludeSimilar) {
        for (String char in _similar.split('')) {
          availableNumbers = availableNumbers.replaceAll(char, '');
        }
      }
      if (availableNumbers.isNotEmpty) {
        password += availableNumbers[random.nextInt(availableNumbers.length)];
      }
    }

    if (_includeSymbols && _symbols.isNotEmpty) {
      String availableSymbols = _symbols;
      if (_excludeAmbiguous) {
        for (String char in _ambiguous.split('')) {
          availableSymbols = availableSymbols.replaceAll(char, '');
        }
      }
      if (availableSymbols.isNotEmpty) {
        password += availableSymbols[random.nextInt(availableSymbols.length)];
      }
    }

    while (password.length < _length.toInt()) {
      password += charset[random.nextInt(charset.length)];
    }

    List<String> passwordList = password.split('');
    passwordList.shuffle(random);
    
    setState(() {
      _generatedPassword = passwordList.join('');
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _generatedPassword));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre panoya kopyalandı')),
      );
    }
  }

  void _usePassword() {
    if (_generatedPassword.isNotEmpty) {
      Navigator.pop(context, _generatedPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Üretici'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generatePassword,
            tooltip: 'Yeni Şifre Üret',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Generated Password Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.vpn_key, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Üretilen Şifre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.copy, color: colorScheme.onSurface.withOpacity(0.6)),
                        onPressed: _copyToClipboard,
                        tooltip: 'Kopyala',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: SelectableText(
                      _generatedPassword.isEmpty ? 'Şifre üretilemiyor' : _generatedPassword,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (_generatedPassword.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SecurityIndicator(password: _generatedPassword),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Password Length
            Text(
              'Şifre Uzunluğu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _length,
                    min: 4,
                    max: 64,
                    divisions: 60,
                    label: _length.round().toString(),
                    activeColor: colorScheme.primary,
                    onChanged: (value) {
                      setState(() => _length = value);
                      _generatePassword();
                    },
                  ),
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    _length.round().toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Karakter Seçenekleri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _buildCheckboxTile(
              'Büyük Harfler (A-Z)',
              _includeUppercase,
              (value) {
                setState(() => _includeUppercase = value!);
                _generatePassword();
              },
            ),

            _buildCheckboxTile(
              'Küçük Harfler (a-z)',
              _includeLowercase,
              (value) {
                setState(() => _includeLowercase = value!);
                _generatePassword();
              },
            ),

            _buildCheckboxTile(
              'Sayılar (0-9)',
              _includeNumbers,
              (value) {
                setState(() => _includeNumbers = value!);
                _generatePassword();
              },
            ),

            _buildCheckboxTile(
              'Semboller (!@#\$%^&*)',
              _includeSymbols,
              (value) {
                setState(() => _includeSymbols = value!);
                _generatePassword();
              },
            ),

            Divider(height: 32, color: colorScheme.outline.withOpacity(0.3)),

            _buildCheckboxTile(
              'Benzer Karakterleri Hariç Tut (il1|o0O)',
              _excludeSimilar,
              (value) {
                setState(() => _excludeSimilar = value!);
                _generatePassword();
              },
            ),

            _buildCheckboxTile(
              'Belirsiz Karakterleri Hariç Tut ({}[]()/\\)',
              _excludeAmbiguous,
              (value) {
                setState(() => _excludeAmbiguous = value!);
                _generatePassword();
              },
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generatePassword,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeni Üret'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generatedPassword.isNotEmpty ? _usePassword : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Kullan'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    final theme = Theme.of(context);
    
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      activeColor: theme.colorScheme.primary,
      checkColor: theme.colorScheme.onPrimary,
    );
  }
}
