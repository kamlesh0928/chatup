import 'package:flutter/material.dart';
import '../../presentation/screens/splash/splash_page.dart';
import '../../presentation/screens/auth/login_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/auth/login';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
  };
}
