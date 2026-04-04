import 'package:aperturely_app/app/theme/app_theme.dart';
import 'package:aperturely_app/app/routes/app_pages.dart';
import 'package:aperturely_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const AperturelyApp());
}

class AperturelyApp extends StatelessWidget {
  const AperturelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aperturely',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          background: AppColors.cream,
        ),
        fontFamily: 'sans-serif',
      ),
      initialRoute: Routes.dashboard,
      getPages: AppPages.routes,
    );
  }
}
