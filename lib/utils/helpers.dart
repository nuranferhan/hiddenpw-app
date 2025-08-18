import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class PasswordHelpers {
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    
    double score = 0.0;
    int length = password.length;
    
    if (length >= 12) {
      score += 40;
    } else if (length >= 8) {
      score += 25;
    } else if (length >= 6) {
      score += 15;
    } else if (length >= 4) {
      score += 5;
    }
    
    int varietyScore = 0;
    
    if (password.contains(RegExp(r'[a-z]'))) {
      varietyScore += 5;
    }
    
    if (password.contains(RegExp(r'[A-Z]'))) {
      varietyScore += 5;
    }
    
    if (password.contains(RegExp(r'[0-9]'))) {
      varietyScore += 10;
    }
    
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:,.<>?]'))) {
      varietyScore += 25;
    }
    
    if (password.contains(RegExp(r'[^\x00-\x7F]'))) {
      varietyScore += 10;
    }
    
    int charTypes = 0;
    if (password.contains(RegExp(r'[a-z]'))) charTypes++;
    if (password.contains(RegExp(r'[A-Z]'))) charTypes++;
    if (password.contains(RegExp(r'[0-9]'))) charTypes++;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:,.<>?]'))) charTypes++;
    
    if (charTypes >= 3) varietyScore += 5;
    
    score += varietyScore;
    
    score -= _checkCommonPatterns(password);
    
    return (score / 100).clamp(0.0, 1.0);
  }
  
  static double _checkCommonPatterns(String password) {
    double deduction = 0.0;
    String lower = password.toLowerCase();
    
    List<String> commonWords = [
      'password', 'şifre', '123456', 'qwerty', 'admin', 'user',
      'guest', 'login', 'welcome', 'secret', 'master', 'root'
    ];
    
    for (String word in commonWords) {
      if (lower.contains(word)) {
        deduction += 20;
        break;
      }
    }
    
    if (RegExp(r'(abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)').hasMatch(lower) ||
        RegExp(r'(123|234|345|456|567|678|789|890)').hasMatch(password)) {
      deduction += 10;
    }
    
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      deduction += 10;
    }
    
    List<String> keyboardPatterns = ['qwerty', 'asdf', 'zxcv', '1234', '4321'];
    for (String pattern in keyboardPatterns) {
      if (lower.contains(pattern)) {
        deduction += 15;
        break;
      }
    }
    
    return deduction;
  }
  
  static String getPasswordStrengthText(String password) {
    double strength = calculatePasswordStrength(password);
    
    if (strength >= 0.8) {
      return 'Çok Güçlü';
    } else if (strength >= 0.6) {
      return 'Güçlü';
    } else if (strength >= 0.4) {
      return 'Orta';
    } else if (strength >= 0.2) {
      return 'Zayıf';
    } else {
      return 'Çok Zayıf';
    }
  }
  
  static Color getPasswordStrengthColor(String password) {
    double strength = calculatePasswordStrength(password);
    
    if (strength >= 0.8) {
      return Colors.green;
    } else if (strength >= 0.6) {
      return Colors.lightGreen;
    } else if (strength >= 0.4) {
      return Colors.orange;
    } else if (strength >= 0.2) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
  
  static Map<String, bool> analyzePassword(String password) {
    return {
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumbers': password.contains(RegExp(r'[0-9]')),
      'hasSymbols': password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:,.<>?]')),
      'hasGoodLength': password.length >= 8,
      'hasVariety': _countCharacterTypes(password) >= 3,
      'noCommonPatterns': _checkCommonPatterns(password) == 0,
    };
  }
  
  static int _countCharacterTypes(String password) {
    int count = 0;
    if (password.contains(RegExp(r'[a-z]'))) count++;
    if (password.contains(RegExp(r'[A-Z]'))) count++;
    if (password.contains(RegExp(r'[0-9]'))) count++;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:,.<>?]'))) count++;
    return count;
  }
  
  static List<String> getPasswordSuggestions(String password) {
    List<String> suggestions = [];
    Map<String, bool> analysis = analyzePassword(password);
    
    if (!analysis['hasGoodLength']!) {
      suggestions.add('Şifrenizi en az 8 karakter yapın');
    }
    
    if (!analysis['hasUppercase']!) {
      suggestions.add('Büyük harf ekleyin (A-Z)');
    }
    
    if (!analysis['hasLowercase']!) {
      suggestions.add('Küçük harf ekleyin (a-z)');
    }
    
    if (!analysis['hasNumbers']!) {
      suggestions.add('Sayı ekleyin (0-9)');
    }
    
    if (!analysis['hasSymbols']!) {
      suggestions.add('Özel karakter ekleyin (!@#\$%^&*)');
    }
    
    if (!analysis['hasVariety']!) {
      suggestions.add('Farklı karakter türlerinden kullanın');
    }
    
    if (_checkCommonPatterns(password) > 0) {
      suggestions.add('Yaygın kelime ve desenleri kullanmayın');
    }
    
    if (password.length > 0 && calculatePasswordStrength(password) < 0.6) {
      suggestions.add('Daha karmaşık bir şifre oluşturun');
    }
    
    return suggestions;
  }
  
  static String formatUrl(String url) {
    if (url.isEmpty) return url;
    
    String formatted = url.replaceFirst(RegExp(r'^https?://'), '');
    
    formatted = formatted.replaceFirst(RegExp(r'^www\.'), '');
    
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    
    return formatted;
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Şimdi';
        } else {
          return '${difference.inMinutes} dk önce';
        }
      } else {
        return '${difference.inHours} sa önce';
      }
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }
}

class DateHelpers {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Şimdi';
        } else {
          return '${difference.inMinutes} dk önce';
        }
      } else {
        return '${difference.inHours} sa önce';
      }
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yıl önce';
    }
  }
  
  static String formatFullDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }
  
  static String formatDateForFile(DateTime date) {
    return DateFormat('yyyy-MM-dd_HH-mm-ss').format(date);
  }
  
  static String formatDateShort(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }
  
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
}

class ValidationHelpers {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
        ? '$fieldName gerekli'
        : AppConstants.emptyFieldError;
    }
    return null;
  }
  
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty emails
    }
    
    if (!RegExp(AppConstants.emailRegex).hasMatch(value)) {
      return AppConstants.invalidEmailError;
    }
    
    return null;
  }
  
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty URLs
    }
    
    String url = value.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    if (!RegExp(AppConstants.urlRegex).hasMatch(url)) {
      return AppConstants.invalidUrlError;
    }
    
    return null;
  }
  
  static String? validatePassword(String? value, {int minLength = 4}) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < minLength) {
      return 'Şifre en az $minLength karakter olmalı';
    }
    
    return null;
  }
  
  static String? validateMasterPassword(String? value) {
    return validatePassword(value, minLength: AppConstants.minMasterPasswordLength);
  }
  
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    final passwordError = validatePassword(value);
    if (passwordError != null) return passwordError;
    
    if (value != originalPassword) {
      return AppConstants.passwordMismatchError;
    }
    
    return null;
  }
  
  static String? validateMaxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return fieldName != null
        ? '$fieldName $maxLength karakterden uzun olamaz'
        : 'Maksimum $maxLength karakter olabilir';
    }
    return null;
  }
}

class StringHelpers {
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
  
  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '');
  }
  
  static String formatUrl(String url) {
    if (url.isEmpty) return url;
    
    String formatted = url.replaceFirst(RegExp(r'^https?://'), '');
    
    formatted = formatted.replaceFirst(RegExp(r'^www\.'), '');
    
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    
    return formatted;
  }
  
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (1000 + (DateTime.now().microsecond % 9000)).toString();
  }
  
  static bool isValidEmail(String email) {
    return RegExp(AppConstants.emailRegex).hasMatch(email);
  }
  
  static bool isValidUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return RegExp(AppConstants.urlRegex).hasMatch(url);
  }
  
  static String maskPassword(String password, {String maskChar = '•'}) {
    return maskChar * password.length;
  }
  
  static String getFileExtension(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }
  
  static String sanitizeFileName(String fileName) {
 
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}

class SecurityHelpers {
  static bool isPasswordCompromised(String password, List<String> compromisedHashes) {
 
    return false; // Placeholder
  }
  
  static String generateSecureId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + DateTime.now().microsecond) % 999999;
    return '$timestamp$random';
  }
  
  static int calculatePasswordEntropy(String password) {
    if (password.isEmpty) return 0;
    
    int characterSetSize = 0;
    
    if (password.contains(RegExp(r'[a-z]'))) characterSetSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) characterSetSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) characterSetSize += 10;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:,.<>?]'))) characterSetSize += 32;
    
    if (characterSetSize == 0) return 0;
    
    return (password.length * (characterSetSize.bitLength - 1)).round();
  }
}

class UIHelpers {
  static void showSnackBar(BuildContext context, String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppConstants.errorColor : null,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String title,
    String content, {
    String confirmText = 'Tamam',
    String cancelText = 'İptal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive 
              ? TextButton.styleFrom(foregroundColor: AppConstants.errorColor)
              : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }
  
  static Color getRandomColor(String seed) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];
    
    final index = seed.hashCode % colors.length;
    return colors[index.abs()];
  }
  
  static String getInitials(String text) {
    if (text.isEmpty) return '?';
    
    final words = text.trim().split(' ');
    if (words.length == 1) {
      return text.substring(0, 1).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }
  }
}

class DebugHelpers {
  static void log(String message) {
    if (AppConstants.enableLogging && AppConstants.isDebugMode) {
      print('[HiddenPW] $message');
    }
  }
  
  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging && AppConstants.isDebugMode) {
      print('[HiddenPW ERROR] $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }
  }
  
  static void logWarning(String message) {
    if (AppConstants.enableLogging && AppConstants.isDebugMode) {
      print('[HiddenPW WARNING] $message');
    }
  }
  
  static void logInfo(String message) {
    if (AppConstants.enableLogging && AppConstants.isDebugMode) {
      print('[HiddenPW INFO] $message');
    }
  }
}

class FileHelpers {
  static String generateBackupFileName({bool encrypted = true}) {
    final timestamp = DateHelpers.formatDateForFile(DateTime.now());
    final suffix = encrypted ? '_encrypted' : '_plain';
    return '${AppConstants.exportFilePrefix}${suffix}_$timestamp${AppConstants.backupFileExtension}';
  }
  
  static String generateAutoBackupFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${AppConstants.autoBackupPrefix}$timestamp${AppConstants.backupFileExtension}';
  }
  
  static bool isValidBackupFile(String fileName) {
    return fileName.endsWith(AppConstants.backupFileExtension) &&
           (fileName.contains(AppConstants.exportFilePrefix) ||
            fileName.contains(AppConstants.autoBackupPrefix));
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

class ThemeHelpers {
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      cardColor: AppConstants.cardColor,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.cardColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppConstants.textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppConstants.textColor),
      ),
      
      cardTheme: CardThemeData(
        color: AppConstants.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: const BorderSide(color: AppConstants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: AppConstants.errorColor),
        ),
        labelStyle: const TextStyle(color: AppConstants.textSecondaryColor),
        hintStyle: TextStyle(color: AppConstants.textSecondaryColor.withOpacity(0.7)),
      ),
      
      listTileTheme: const ListTileThemeData(
        textColor: AppConstants.textColor,
        iconColor: AppConstants.primaryColor,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppConstants.primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppConstants.primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.3);
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppConstants.primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: AppConstants.textSecondaryColor),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppConstants.primaryColor;
          }
          return AppConstants.textSecondaryColor;
        }),
      ),
      
      sliderTheme: SliderThemeData(
        activeTrackColor: AppConstants.primaryColor,
        inactiveTrackColor: AppConstants.primaryColor.withOpacity(0.3),
        thumbColor: AppConstants.primaryColor,
        overlayColor: AppConstants.primaryColor.withOpacity(0.2),
        valueIndicatorColor: AppConstants.primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.cardColor,
        contentTextStyle: const TextStyle(color: AppConstants.textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: AppConstants.cardColor,
        titleTextStyle: const TextStyle(
          color: AppConstants.textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      
      dividerTheme: DividerThemeData(
        color: Colors.grey.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      
      iconTheme: const IconThemeData(
        color: AppConstants.textSecondaryColor,
        size: AppConstants.iconSize,
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppConstants.textColor),
        displayMedium: TextStyle(color: AppConstants.textColor),
        displaySmall: TextStyle(color: AppConstants.textColor),
        headlineLarge: TextStyle(color: AppConstants.textColor),
        headlineMedium: TextStyle(color: AppConstants.textColor),
        headlineSmall: TextStyle(color: AppConstants.textColor),
        titleLarge: TextStyle(color: AppConstants.textColor),
        titleMedium: TextStyle(color: AppConstants.textColor),
        titleSmall: TextStyle(color: AppConstants.textColor),
        bodyLarge: TextStyle(color: AppConstants.textColor),
        bodyMedium: TextStyle(color: AppConstants.textColor),
        bodySmall: TextStyle(color: AppConstants.textSecondaryColor),
        labelLarge: TextStyle(color: AppConstants.textColor),
        labelMedium: TextStyle(color: AppConstants.textSecondaryColor),
        labelSmall: TextStyle(color: AppConstants.textSecondaryColor),
      ),
    );
  }
  
  static Color getStrengthColor(double strength) {
    if (strength >= 0.8) return Colors.green;
    if (strength >= 0.6) return Colors.lightGreen;
    if (strength >= 0.4) return Colors.orange;
    if (strength >= 0.2) return Colors.deepOrange;
    return Colors.red;
  }
}

class AnimationHelpers {
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0.0, 1.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.elasticOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}

class PlatformHelpers {
  static bool get isAndroid => Theme.of(NavigationService.navigatorKey.currentContext!).platform == TargetPlatform.android;
  static bool get isIOS => Theme.of(NavigationService.navigatorKey.currentContext!).platform == TargetPlatform.iOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => !isMobile;
  
  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    return 'Unknown';
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static BuildContext? get currentContext => navigatorKey.currentContext;
  
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  static Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }
  
  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }
  
  static Future<T?> pushNamedAndRemoveUntil<T>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }
}