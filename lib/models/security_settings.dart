import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SecuritySettings {
  final bool biometricEnabled;
  final bool autoLockEnabled;
  final int autoLockMinutes;
  final bool autoBackupEnabled;
  final bool breachCheckEnabled;
  final bool passwordStrengthCheckEnabled;
  final bool clipboardClearEnabled;
  final int clipboardClearSeconds;
  final bool showPasswordsEnabled;
  final bool failedAttemptsLockEnabled;
  final int maxFailedAttempts;
  final bool sessionTimeoutEnabled;
  final int sessionTimeoutMinutes;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool compromisedPasswordAlertsEnabled;
  final String lastBackupDate;
  final int totalPasswords;
  final int compromisedPasswords;

  SecuritySettings({
    this.biometricEnabled = false,
    this.autoLockEnabled = true,
    this.autoLockMinutes = AppConstants.defaultAutoLockMinutes,
    this.autoBackupEnabled = false,
    this.breachCheckEnabled = AppConstants.enableBreachCheck,
    this.passwordStrengthCheckEnabled = true,
    this.clipboardClearEnabled = true,
    this.clipboardClearSeconds = 30,
    this.showPasswordsEnabled = false,
    this.failedAttemptsLockEnabled = true,
    this.maxFailedAttempts = 5,
    this.sessionTimeoutEnabled = true,
    this.sessionTimeoutMinutes = 30,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.compromisedPasswordAlertsEnabled = true,
    this.lastBackupDate = '',
    this.totalPasswords = 0,
    this.compromisedPasswords = 0,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      biometricEnabled: json['biometricEnabled'] ?? false,
      autoLockEnabled: json['autoLockEnabled'] ?? true,
      autoLockMinutes: json['autoLockMinutes'] ?? AppConstants.defaultAutoLockMinutes,
      autoBackupEnabled: json['autoBackupEnabled'] ?? false,
      breachCheckEnabled: json['breachCheckEnabled'] ?? AppConstants.enableBreachCheck,
      passwordStrengthCheckEnabled: json['passwordStrengthCheckEnabled'] ?? true,
      clipboardClearEnabled: json['clipboardClearEnabled'] ?? true,
      clipboardClearSeconds: json['clipboardClearSeconds'] ?? 30,
      showPasswordsEnabled: json['showPasswordsEnabled'] ?? false,
      failedAttemptsLockEnabled: json['failedAttemptsLockEnabled'] ?? true,
      maxFailedAttempts: json['maxFailedAttempts'] ?? 5,
      sessionTimeoutEnabled: json['sessionTimeoutEnabled'] ?? true,
      sessionTimeoutMinutes: json['sessionTimeoutMinutes'] ?? 30,
      themeMode: _themeFromString(json['themeMode'] ?? 'system'),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      compromisedPasswordAlertsEnabled: json['compromisedPasswordAlertsEnabled'] ?? true,
      lastBackupDate: json['lastBackupDate'] ?? '',
      totalPasswords: json['totalPasswords'] ?? 0,
      compromisedPasswords: json['compromisedPasswords'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'biometricEnabled': biometricEnabled,
      'autoLockEnabled': autoLockEnabled,
      'autoLockMinutes': autoLockMinutes,
      'autoBackupEnabled': autoBackupEnabled,
      'breachCheckEnabled': breachCheckEnabled,
      'passwordStrengthCheckEnabled': passwordStrengthCheckEnabled,
      'clipboardClearEnabled': clipboardClearEnabled,
      'clipboardClearSeconds': clipboardClearSeconds,
      'showPasswordsEnabled': showPasswordsEnabled,
      'failedAttemptsLockEnabled': failedAttemptsLockEnabled,
      'maxFailedAttempts': maxFailedAttempts,
      'sessionTimeoutEnabled': sessionTimeoutEnabled,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'themeMode': _themeToString(themeMode),
      'notificationsEnabled': notificationsEnabled,
      'compromisedPasswordAlertsEnabled': compromisedPasswordAlertsEnabled,
      'lastBackupDate': lastBackupDate,
      'totalPasswords': totalPasswords,
      'compromisedPasswords': compromisedPasswords,
    };
  }

  SecuritySettings copyWith({
    bool? biometricEnabled,
    bool? autoLockEnabled,
    int? autoLockMinutes,
    bool? autoBackupEnabled,
    bool? breachCheckEnabled,
    bool? passwordStrengthCheckEnabled,
    bool? clipboardClearEnabled,
    int? clipboardClearSeconds,
    bool? showPasswordsEnabled,
    bool? failedAttemptsLockEnabled,
    int? maxFailedAttempts,
    bool? sessionTimeoutEnabled,
    int? sessionTimeoutMinutes,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? compromisedPasswordAlertsEnabled,
    String? lastBackupDate,
    int? totalPasswords,
    int? compromisedPasswords,
  }) {
    return SecuritySettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      breachCheckEnabled: breachCheckEnabled ?? this.breachCheckEnabled,
      passwordStrengthCheckEnabled: passwordStrengthCheckEnabled ?? this.passwordStrengthCheckEnabled,
      clipboardClearEnabled: clipboardClearEnabled ?? this.clipboardClearEnabled,
      clipboardClearSeconds: clipboardClearSeconds ?? this.clipboardClearSeconds,
      showPasswordsEnabled: showPasswordsEnabled ?? this.showPasswordsEnabled,
      failedAttemptsLockEnabled: failedAttemptsLockEnabled ?? this.failedAttemptsLockEnabled,
      maxFailedAttempts: maxFailedAttempts ?? this.maxFailedAttempts,
      sessionTimeoutEnabled: sessionTimeoutEnabled ?? this.sessionTimeoutEnabled,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      compromisedPasswordAlertsEnabled: compromisedPasswordAlertsEnabled ?? this.compromisedPasswordAlertsEnabled,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      totalPasswords: totalPasswords ?? this.totalPasswords,
      compromisedPasswords: compromisedPasswords ?? this.compromisedPasswords,
    );
  }

  double get securityLevel {
    double score = 0.0;
    int totalChecks = 10;

    if (biometricEnabled) score += 0.15;

    if (autoLockEnabled) score += 0.15;

    if (autoLockEnabled && autoLockMinutes <= 5) score += 0.1;

    if (breachCheckEnabled) score += 0.15;

    if (passwordStrengthCheckEnabled) score += 0.1;

    if (clipboardClearEnabled) score += 0.1;

    if (failedAttemptsLockEnabled) score += 0.1;

    if (sessionTimeoutEnabled) score += 0.1;

    if (compromisedPasswordAlertsEnabled) score += 0.05;

    return score;
  }

  String get securityLevelText {
    final level = securityLevel;
    if (level >= 0.9) return 'Çok Güvenli';
    if (level >= 0.7) return 'Güvenli';
    if (level >= 0.5) return 'Orta';
    if (level >= 0.3) return 'Düşük';
    return 'Çok Düşük';
  }

  Color get securityLevelColor {
    final level = securityLevel;
    if (level >= 0.9) return AppConstants.successColor;
    if (level >= 0.7) return Colors.lightGreen;
    if (level >= 0.5) return AppConstants.warningColor;
    if (level >= 0.3) return Colors.deepOrange;
    return AppConstants.errorColor;
  }

  String get autoLockText {
    if (!autoLockEnabled) return 'Kapalı';
    if (autoLockMinutes == 1) return '1 dakika';
    return '$autoLockMinutes dakika';
  }

  String get clipboardClearText {
    if (!clipboardClearEnabled) return 'Kapalı';
    return '$clipboardClearSeconds saniye';
  }

  String get themeModeText {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
      case ThemeMode.system:
        return 'Sistem';
    }
  }

  List<SecurityRecommendation> get recommendations {
    List<SecurityRecommendation> recommendations = [];

    if (!biometricEnabled) {
      recommendations.add(SecurityRecommendation(
        title: 'Biyometrik Doğrulamayı Etkinleştirin',
        description: 'Parmak izi veya yüz tanıma ile ekstra güvenlik sağlayın.',
        priority: RecommendationPriority.high,
        action: SecurityAction.enableBiometric,
      ));
    }

    if (!autoLockEnabled) {
      recommendations.add(SecurityRecommendation(
        title: 'Otomatik Kilidi Etkinleştirin',
        description: 'Uygulamayı kullanmadığınızda otomatik olarak kilitlensin.',
        priority: RecommendationPriority.high,
        action: SecurityAction.enableAutoLock,
      ));
    }

    if (autoLockEnabled && autoLockMinutes > 15) {
      recommendations.add(SecurityRecommendation(
        title: 'Otomatik Kilit Süresini Azaltın',
        description: 'Daha kısa kilit süresi ile güvenliği artırın.',
        priority: RecommendationPriority.medium,
        action: SecurityAction.reduceAutoLockTime,
      ));
    }

    if (!breachCheckEnabled) {
      recommendations.add(SecurityRecommendation(
        title: 'Güvenlik İhlali Kontrolünü Etkinleştirin',
        description: 'Şifrelerinizin veri sızıntılarında olup olmadığını kontrol edin.',
        priority: RecommendationPriority.medium,
        action: SecurityAction.enableBreachCheck,
      ));
    }

    if (!clipboardClearEnabled) {
      recommendations.add(SecurityRecommendation(
        title: 'Pano Temizlemeyi Etkinleştirin',
        description: 'Kopyalanan şifreler otomatik olarak panodan silinsin.',
        priority: RecommendationPriority.low,
        action: SecurityAction.enableClipboardClear,
      ));
    }

    if (compromisedPasswords > 0) {
      recommendations.add(SecurityRecommendation(
        title: 'Güvenliği İhlal Edilmiş Şifreleri Değiştirin',
        description: '$compromisedPasswords adet şifreniz güvenlik ihlalinde tespit edildi.',
        priority: RecommendationPriority.critical,
        action: SecurityAction.changeCompromisedPasswords,
      ));
    }

    return recommendations;
  }

  static ThemeMode _themeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeToString(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecuritySettings &&
          runtimeType == other.runtimeType &&
          biometricEnabled == other.biometricEnabled &&
          autoLockEnabled == other.autoLockEnabled &&
          autoLockMinutes == other.autoLockMinutes &&
          autoBackupEnabled == other.autoBackupEnabled &&
          breachCheckEnabled == other.breachCheckEnabled &&
          passwordStrengthCheckEnabled == other.passwordStrengthCheckEnabled &&
          clipboardClearEnabled == other.clipboardClearEnabled &&
          clipboardClearSeconds == other.clipboardClearSeconds &&
          showPasswordsEnabled == other.showPasswordsEnabled &&
          failedAttemptsLockEnabled == other.failedAttemptsLockEnabled &&
          maxFailedAttempts == other.maxFailedAttempts &&
          sessionTimeoutEnabled == other.sessionTimeoutEnabled &&
          sessionTimeoutMinutes == other.sessionTimeoutMinutes &&
          themeMode == other.themeMode &&
          notificationsEnabled == other.notificationsEnabled &&
          compromisedPasswordAlertsEnabled == other.compromisedPasswordAlertsEnabled;

  @override
  int get hashCode => Object.hash(
        biometricEnabled,
        autoLockEnabled,
        autoLockMinutes,
        autoBackupEnabled,
        breachCheckEnabled,
        passwordStrengthCheckEnabled,
        clipboardClearEnabled,
        clipboardClearSeconds,
        showPasswordsEnabled,
        failedAttemptsLockEnabled,
        maxFailedAttempts,
        sessionTimeoutEnabled,
        sessionTimeoutMinutes,
        themeMode,
        notificationsEnabled,
        compromisedPasswordAlertsEnabled,
      );

  @override
  String toString() {
    return 'SecuritySettings{biometricEnabled: $biometricEnabled, autoLockEnabled: $autoLockEnabled, securityLevel: ${securityLevel.toStringAsFixed(2)}}';
  }
}

class SecurityRecommendation {
  final String title;
  final String description;
  final RecommendationPriority priority;
  final SecurityAction action;

  SecurityRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.action,
  });

  Color get priorityColor {
    switch (priority) {
      case RecommendationPriority.critical:
        return AppConstants.errorColor;
      case RecommendationPriority.high:
        return Colors.deepOrange;
      case RecommendationPriority.medium:
        return AppConstants.warningColor;
      case RecommendationPriority.low:
        return Colors.blue;
    }
  }

  String get priorityText {
    switch (priority) {
      case RecommendationPriority.critical:
        return 'Kritik';
      case RecommendationPriority.high:
        return 'Yüksek';
      case RecommendationPriority.medium:
        return 'Orta';
      case RecommendationPriority.low:
        return 'Düşük';
    }
  }
}

enum RecommendationPriority {
  critical,
  high,
  medium,
  low,
}

enum SecurityAction {
  enableBiometric,
  enableAutoLock,
  reduceAutoLockTime,
  enableBreachCheck,
  enableClipboardClear,
  changeCompromisedPasswords,
  enableAutoBackup,
  updateMasterPassword,
}