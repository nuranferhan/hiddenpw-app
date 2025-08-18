import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(400, 800), // iPhone benzeri boyut
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      minimumSize: Size(350, 600), // Minimum boyut
      maximumSize: Size(450, 900), // Maximum boyut
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  
  await StorageService.instance.init();
  await ThemeService.instance.init();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(
    DevicePreview(
      enabled: !Platform.isAndroid && !Platform.isIOS, // Sadece desktop'ta aktif
      defaultDevice: Devices.ios.iPhoneSE, // Varsayılan cihaz
      devices: [
        Devices.ios.iPhoneSE,
        Devices.ios.iPhone12,
        Devices.ios.iPhone13ProMax,
        Devices.android.samsungGalaxyS20,
        Devices.android.samsungGalaxyNote20,
      ],
      builder: (context) => const HiddenPWApp(),
    ),
  );
}

class HiddenPWApp extends StatelessWidget {
  const HiddenPWApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeService.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'HiddenPW',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeService.instance.themeMode,
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          
          home: const SplashScreen(),
        );
      },
    );
  }
}