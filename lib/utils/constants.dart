import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'HiddenPW';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Güvenli Şifre Yöneticisi';
  
 
  static const Color primaryColor = Colors.blue;
  static const Color backgroundColor = Color(0xFF1A1A1A);
  static const Color cardColor = Color(0xFF2D2D2D);
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Colors.grey;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardColor, backgroundColor],
  );
  
  static const String databaseName = 'hiddenPW.db';
  static const int databaseVersion = 1;
  static const String passwordsTableName = 'passwords';
  
  static const int minPasswordLength = 4;
  static const int minMasterPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int pbkdf2Iterations = 10000;
  static const String saltKey = 'HiddenPW-Salt';
  static const String passwordSaltKey = 'HiddenPW-Password-Salt';
  
  static const String masterPasswordHashKey = 'master_password_hash';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String autoLockEnabledKey = 'auto_lock_enabled';
  static const String autoLockMinutesKey = 'auto_lock_minutes';
  static const String lastActiveTimeKey = 'last_active_time';
  static const String themeKey = 'theme_mode';
  
 
  static const int maxAutoBackups = 5;
  static const String backupDirectoryName = 'backups';
  static const String autoBackupPrefix = 'auto_backup_';
  static const String backupFileExtension = '.json';
  
  static const Map<String, double> strengthThresholds = {
    'very_weak': 0.0,
    'weak': 0.2,
    'fair': 0.4,
    'good': 0.6,
    'strong': 0.8,
    'very_strong': 1.0,
  };
  
  static const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String numberChars = '0123456789';
  static const String symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const String similarChars = 'il1Lo0O';
  static const String ambiguousChars = '{}[]()/\\\'"`~,;.<>';
  
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 50.0;
  static const double iconSize = 24.0;
  static const double avatarRadius = 24.0;
  
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
  
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  static const List<int> autoLockOptions = [1, 5, 10, 15, 30, 60];
  
  static const String breachCheckApiUrl = 'https://api.pwnedpasswords.com/range/';
  static const String userAgent = 'HiddenPW-App';
  static const Duration breachCheckTimeout = Duration(seconds: 10);
  static const Duration breachCheckDelay = Duration(milliseconds: 100);
  
  static const String exportFilePrefix = 'hiddenPW_backup';
  static const String exportDateFormat = 'yyyy-MM-dd_HH-mm-ss';
  static const String backupVersion = '1.0.0';
  
  static const String emptyFieldError = 'Bu alan boş bırakılamaz';
  static const String shortPasswordError = 'Şifre çok kısa';
  static const String weakPasswordWarning = 'Şifre çok zayıf';
  static const String passwordMismatchError = 'Şifreler eşleşmiyor';
  static const String invalidUrlError = 'Geçersiz URL formatı';
  static const String invalidEmailError = 'Geçersiz e-posta formatı';
  
  static const String passwordSavedSuccess = 'Şifre başarıyla kaydedildi';
  static const String passwordUpdatedSuccess = 'Şifre başarıyla güncellendi';
  static const String passwordDeletedSuccess = 'Şifre başarıyla silindi';
  static const String masterPasswordChangedSuccess = 'Ana şifre başarıyla değiştirildi';
  static const String dataExportedSuccess = 'Veriler başarıyla dışa aktarıldı';
  static const String dataImportedSuccess = 'Veriler başarıyla içe aktarıldı';
  static const String passwordCopiedSuccess = 'Şifre panoya kopyalandı';
  static const String usernameCopiedSuccess = 'Kullanıcı adı panoya kopyalandı';
  
  static const String genericError = 'Bir hata oluştu';
  static const String networkError = 'Ağ bağlantısı hatası';
  static const String authenticationError = 'Kimlik doğrulama hatası';
  static const String biometricNotAvailableError = 'Biyometrik kimlik doğrulama bu cihazda desteklenmiyor';
  static const String exportError = 'Dışa aktarma hatası';
  static const String importError = 'İçe aktarma hatası';
  static const String decryptionError = 'Şifre çözme hatası';
  static const String encryptionError = 'Şifreleme hatası';
  static const String storageError = 'Veri saklama hatası';
  static const String breachCheckError = 'Güvenlik kontrolü yapılamadı';
  
  static const String compromisedPasswordWarning = 'Bu şifre güvenlik ihlalinde tespit edilmiş!';
  static const String weakPasswordWarning2 = 'Şifreniz zayıf, güçlendirmeniz önerilir';
  static const String deleteConfirmation = 'Bu işlem geri alınamaz. Devam etmek istediğinizden emin misiniz?';
  static const String clearAllDataWarning = 'Tüm şifreleriniz silinecek. Bu işlem geri alınamaz!';
  
  static const String noPasswordsFound = 'Henüz kayıtlı şifre yok';
  static const String noSearchResults = 'Arama sonucu bulunamadı';
  static const String addFirstPassword = 'İlk şifrenizi eklemek için + butonuna basın';
  static const String passwordGeneratorInfo = 'Güçlü bir şifre oluşturmak için seçenekleri ayarlayın';
  
  static const String biometricPrompt = 'HiddenPW\'ye erişmek için kimliğinizi doğrulayın';
  static const String biometricCancelButton = 'İptal';
  static const String biometricFallbackTitle = 'Ana Şifre Kullan';
  
  static const Map<String, ThemeMode> themeModes = {
    'system': ThemeMode.system,
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
  };
  
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String urlRegex = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  
  static const List<String> supportedImportTypes = ['json'];
  static const List<String> supportedExportTypes = ['json'];
  
  static const int maxTitleLength = 100;
  static const int maxUsernameLength = 100;
  static const int maxUrlLength = 500;
  static const int maxNotesLength = 1000;
  static const int maxSearchResults = 100;
  
  static const int defaultPasswordLength = 16;
  static const int defaultAutoLockMinutes = 5;
  static const bool defaultIncludeUppercase = true;
  static const bool defaultIncludeLowercase = true;
  static const bool defaultIncludeNumbers = true;
  static const bool defaultIncludeSymbols = true;
  static const bool defaultExcludeSimilar = false;
  static const bool defaultExcludeAmbiguous = false;

  static const bool enableBiometrics = true;
  static const bool enableBreachCheck = true;
  static const bool enableAutoBackup = true;
  static const bool enablePasswordGenerator = true;
  static const bool enableExportImport = true;
  
  static const bool isDebugMode = false; // Set to false for production
  static const bool enableLogging = false; // Set to false for production
}