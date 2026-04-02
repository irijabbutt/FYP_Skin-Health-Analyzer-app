// -----------------------------------------------
// Project: Skin Health Analyzer
// File: main.dart
// Developer: Rijab Butt, Maryam Waheed, Muhammad Mubashir, Azka Naaz
// Description: App entry point with Supabase & TFLite init
// -----------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Services/tflite_service.dart';
import 'Utils/app_config.dart';
import 'Views/First Screen/get_started.dart';
import 'Views/Bottom Bar/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Pre-load TFLite model in background
  TFLiteService().loadModel().catchError((e) {
    debugPrint('[Main] TFLite preload error: $e');
  });

  runApp(const SkinAnalyzerApp());
}

class SkinAnalyzerApp extends StatelessWidget {
  const SkinAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 880),
      minTextAdapt: false,
      splitScreenMode: false,
      builder: (_, child) {
        return GetMaterialApp(
          title: 'Skin Health Analyzer',
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fadeIn,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFFC1CC),
              brightness: Brightness.light,
            ),
            fontFamily: 'Roboto',
          ),
          home: const _AuthGate(),
        );
      },
    );
  }
}

/// Routes to correct screen based on auth state
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const SkinNavigationBar();
    }
    return const SkinDiscoverScreen();
  }
}
