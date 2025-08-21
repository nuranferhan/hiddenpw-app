# HiddenPW - Secure Password Manager

<div align="center">
 <img src="https://img.shields.io/badge/HiddenPW-Flutter%20Security-2196F3?style=for-the-badge" alt="HiddenPW" />
 <img src="https://img.shields.io/badge/License-MIT-06B6D4?style=for-the-badge" alt="License" />
 <img src="https://img.shields.io/badge/Flutter-3.16+-02569B?style=for-the-badge&logo=flutter" alt="Flutter" />
 <img src="https://img.shields.io/badge/Security-AES--256-FF5722?style=for-the-badge&logo=security" alt="AES-256" />
</div>

<div align="center">
<img src="https://img.shields.io/badge/Cross--Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-4CAF50?style=for-the-badge" alt="Cross Platform" />
</div>

<div align="center">
  <img width="100%" alt="Image 1" src="https://github.com/user-attachments/assets/273c2b4c-00dc-4ceb-ab4a-45b8d8786dd7" />
</div> 

## Project Overview

<div align="center">
  <img width="28.41%" alt="Image 2" src="https://github.com/user-attachments/assets/db3817ed-ee44-4ae1-b820-497725d0e529" />
  <img width="55%" alt="Image 1" src="https://github.com/user-attachments/assets/1300e422-a7ee-46b3-a9ea-499fcdb3bab5" />
</div>

**HiddenPW** is a production ready, cross platform password management application built with Flutter. Demonstrating advanced mobile security development capabilities through enterprise grade encryption, biometric authentication and offline first architecture. Designed with professional security standards, HiddenPW provides comprehensive password management while maintaining complete offline operation for core security functions.

**Key Features:** 
- **Enterprise grade AES-256-CBC encryption** with custom PBKDF2 implementation (10,000 iterations)
- **Cross platform desktop & mobile** with responsive window management
- **Biometric authentication** with TouchID, FaceID and fingerprint scanner support
- **Offline first architecture** ensuring complete privacy and zero network dependency for core operations
- **Secure password generator** with customizable complexity parameters
- **Breach detection integration** with HaveIBeenPwned API using k-anonymity model
- **Real time security dashboard** with password strength analysis and compromise alerting
- **Professional Turkish localization** with native user experience
- **Timer based auto refresh** with real time data synchronization

## Technical Architecture

<div align="center">
  <img width="60%" alt="Image 1" src="https://github.com/user-attachments/assets/dd832600-46de-4ac4-be1f-fd14e38713eb" />
  <img width="28.1%" alt="Image 2" src="https://github.com/user-attachments/assets/2a760984-801c-4101-862a-4b57bc82f914" />
</div>

### Security Implementation
Multi layered security architecture with enterprise grade protection:

- **AES-256-CBC Encryption**: Industry standard symmetric encryption with unique IV per operation
- **Custom PBKDF2 Implementation**: 10,000 iterations with SHA-256 HMAC for secure key generation
- **Platform Security Integration**: Flutter Secure Storage with hardware backed security
- **Biometric Authentication**: LocalAuth with comprehensive error handling and fallback mechanisms
- **k-Anonymity Breach Checking**: SHA-1 prefix matching with HaveIBeenPwned API (privacy preserving)
- **Memory Protection**: Automatic cleanup of sensitive data with secure disposal
- **Input Validation**: Comprehensive field validation with configurable security limits

### Technology Stack
```
Frontend:     Flutter 3.16+ | Dart 3.0+ | Material Design 3 with Turkish localization
Database:     SQLite3 with AES-256 encrypted password fields
Security:     Custom AES-256-CBC | PBKDF2 | SHA-256 | LocalAuth biometrics
Platforms:    Android 6.0+ | iOS 11.0+ | Windows 10+ | macOS 10.14+ | Linux
Storage:      Flutter Secure Storage with platform specific backends
Architecture: Window Manager | Device Preview | Professional constants management
```

## Core Features

### Password Management
- **Complete CRUD operations** with real time AES-256 encryption/decryption
- **Advanced search and filtering** with live results across encrypted database
- **Password strength analysis** with visual security indicators (0-100 scoring)
- **Compromise detection** with automatic flagging and security alerts
- **Secure metadata storage** for titles, usernames, URLs and notes
- **Export/import functionality** with JSON based encrypted backup system

### Security Dashboard
- **Real time statistics**: Total passwords, compromised count, security score breakdown
- **Visual security indicators** with color coded risk assessment (safe/risky/compromised)
- **Automatic breach monitoring** with periodic security health checks
- **Password strength distribution** with weakness identification and recommendations
- **Timer based auto refresh** ensuring up to date security status

### Advanced Security Features
- **Master password protection** with custom PBKDF2 derived encryption (10,000 iterations)
- **Biometric authentication** with platform hardware integration and comprehensive error handling
- **Dynamic theme system** with persistent user preferences and Material Design 3
<div align="center">
  <img width="80%" alt="Image 1" src="https://github.com/user-attachments/assets/6a85ed28-4556-4d27-b6ba-a38a0d5bf7ca" />
</div>

- **Professional settings management** with secure configuration options
- **Breach detection system** using HaveIBeenPwned k-anonymity model with SHA-1 prefix matching
- **Memory safe operations** with automatic sensitive data cleanup
- **Professional error handling** with comprehensive Turkish localized feedback
  
### Password Generator
<div align="center">
  <img width="30%" alt="Image 1" src="https://github.com/user-attachments/assets/1e101522-3989-4c38-a79e-5ffd1aa8b678" />
</div>

- **Secure generation** with customizable parameters (length, character sets, complexity rules)
- **Real time strength validation** with integrated security analysis
- **Professional UX**: character category selection, instant generation, copy to clipboard functionality
- **Flexible character control**: uppercase, lowercase, numbers, symbols with security filtering
- **Advanced options**: similar/ambiguous character exclusion for enhanced security

### Cross Platform Excellence  
- **Native desktop integration** with Window Manager for proper window sizing and management
- **Adaptive UI design** following platform specific design guidelines
- **Device Preview support** for development with multiple device profiles (iPhone SE, Galaxy S20, etc.)
- **Responsive layouts** supporting various screen sizes and orientations
- **Professional Turkish localization** with native user experience

## Installation & Setup

### Prerequisites
```bash
Flutter SDK: 3.16.0+
Dart SDK: 3.0.0+
```

### Setup Instructions
```bash

# Install dependencies
flutter pub get

# Verify environment
flutter doctor -v

# Run development build
flutter run
```

### Platform Configuration

**Android (API 23+):**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

**iOS (11.0+):**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSFaceIDUsageDescription</key>
<string>HiddenPW uses biometric authentication to secure your passwords</string>
```

## Project Architecture

```
hidden_pw/
├── android/                                 # Android platform configuration
├── ios/                                     # iOS platform configuration  
├── windows/                                 # Windows desktop configuration
├── macos/                                   # macOS desktop configuration
├── linux/                                   # Linux desktop configuration
└── lib/                                     # Flutter source code
    ├── main.dart                            # Application entry point with platform setup
    ├── models/                              # Data models and entities
    │   ├── password_entry.dart              # Password entry model with JSON serialization
    │   └── security_settings.dart           # Security configuration model
    ├── screens/                             # User interface screens
    │   ├── splash_screen.dart               # App initialization and loading
    │   ├── auth_screen.dart                 # Master password and biometric authentication
    │   ├── home_screen.dart                 # Main password list with search and statistics
    │   ├── add_password_screen.dart         # Password creation and editing
    │   ├── password_detail_screen.dart      # Password viewing and management
    │   ├── settings_screen.dart             # App configuration and security settings
    │   └── password_generator_screen.dart   # Secure password generation
    ├── services/                            # Core business logic and security services
    │   ├── encryption_service.dart          # AES-256 encryption and key management
    │   ├── storage_service.dart             # SQLite database with encrypted storage
    │   ├── biometric_service.dart           # Biometric authentication integration
    │   ├── backup_service.dart              # Encrypted backup and restore functionality
    │   ├── breach_checker_service.dart      # HaveIBeenPwned API integration
    │   └── theme_service.dart               # Dark/light theme management
    ├── widgets/                             # Reusable UI components
    │   ├── password_card.dart               # Password entry display component
    │   ├── security_indicator.dart          # Password strength visualization
    │   └── custom_text_field.dart           # Secure input field with validation
    └── utils/                               # Utility functions and constants
        ├── constants.dart                   # App constants and configuration
        └── helpers.dart                     # Utility functions and validators
├── pubspec.yaml                             # Flutter dependencies and configuration
└── README.md                                # Project documentation
```

## Security Standards & Best Practices

### Cryptographic Implementation
- **AES-256-CBC**: NIST approved symmetric encryption with 256 bit keys
- **Custom PBKDF2**: 10,000 iterations with SHA-256 HMAC for key strengthening
- **Unique IV Generation**: Cryptographically secure random IV per encryption operation
- **k-Anonymity Model**: Privacy-preserving breach detection via SHA-1 prefix matching
- **Secure Memory Management**: Automatic cleanup of sensitive data structures

### Production Security Features
- **Defense in Depth**: Multiple security layers with comprehensive validation
- **Zero Network Dependency**: Complete offline operation for core security functions  
- **Hardware Security Integration**: Platform specific secure storage and biometrics
- **Professional Error Handling**: Comprehensive exception management with Turkish localization
- **Input Validation**: Configurable limits with format validation and sanitization
- **Security Monitoring**: Real time password health analysis and breach alerting

## Build & Deployment

### Development Build
```bash
flutter run --debug --device-id=windows
```

### Production Build
```bash
# Android Release
flutter build apk --release --obfuscate --split-debug-info=./debug-info/

# iOS Release  
flutter build ipa --release --obfuscate --split-debug-info=./debug-info/

# Desktop Releases
flutter build windows --release
flutter build macos --release  
flutter build linux --release
```

### Security Hardening
- **Code Obfuscation**: Dart code obfuscation for release builds
- **Debug Info Separation**: Split debug information for production security
- **Platform Optimization**: Platform specific build configurations
- **Asset Protection**: Secure asset bundling and resource protection

## Testing & Quality Assurance

- **Security Testing**: Cryptographic operation validation and timing analysis
- **Cross Platform Testing**: Functionality verification across all supported platforms
- **Performance Testing**: Encryption operation benchmarks (<100ms target)
- **UI Testing**: Device Preview integration for responsive design validation
- **Integration Testing**: End to end security workflow verification

## Professional Applications

This project demonstrates advanced capabilities in:

- **Enterprise Security Development**: Production-grade cryptographic implementation with custom PBKDF2
- **Cross Platform Architecture**: Unified codebase with platform specific optimizations  
- **Advanced Flutter Development**: Complex state management with native platform integration
- **Security Best Practices**: Defense in depth approach with comprehensive protection layers
- **Professional Code Organization**: Scalable architecture with proper separation of concerns
- **Production Deployment**: Release-ready builds with security hardening and obfuscation

## Technical Achievements

- **Custom Cryptographic Implementation**: Professional PBKDF2 implementation with 10,000 iterations
- **Zero dependency Core Security**: Complete offline operation for all sensitive operations
- **Hardware Security Integration**: Platform-specific biometric authentication and secure storage
- **Privacy Preserving Breach Detection**: k-Anonymity model implementation with SHA-1 prefix matching
- **Real time Security Analysis**: Live password strength calculation and compromise detection
- **Professional Turkish Localization**: Native user experience with comprehensive language support
- **Production Ready Architecture**: Comprehensive error handling, logging and professional polish

## Conclusion

HiddenPW represents a comprehensive demonstration of modern mobile security development, showcasing advanced proficiency in Flutter development while implementing enterprise grade cryptographic standards and security best practices. The project exemplifies the ability to deliver production quality security applications that balance robust protection with exceptional user experience across multiple platforms.

The application demonstrates mastery of cross platform development, cryptographic implementation, biometric authentication and offline first architecture principles. Through its security focused design and comprehensive feature set, HiddenPW establishes itself as a professional-grade password management solution suitable for both individual users and enterprise environments.

---

**Technology Stack:** Flutter • Dart • SQLite • Custom AES-256-CBC • PBKDF2 • Biometric Authentication • Cross Platform Desktop Integration

**Security Standards:** Custom cryptographic implementation • k-Anonymity privacy model • Hardware backed security • Defense in depth architecture



