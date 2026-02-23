/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 05, 2026
    Developer: Rijab Butt
    ---------------------------------------
    Description: Main.dart file is a entry file
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import 'Views/First Screen/get_started.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return ScreenUtilInit(
      designSize: Size(375, 880),
      minTextAdapt: false,
      splitScreenMode: false,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.leftToRight,
          home: SkinDiscoverScreen(),
        );
      },
    );
  }
}
