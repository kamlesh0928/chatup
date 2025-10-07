import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/presentation/screens/splash/splash_screen.dart';
import 'package:chatup/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:chatup/config/theme/app_theme.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatUp',
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
