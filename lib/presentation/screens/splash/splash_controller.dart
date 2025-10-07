import 'package:flutter/material.dart';
import '../../../data/services/service_locator.dart';
import '../../../data/services/storage_service.dart';
import '../../../router/app_router.dart';
import '../auth/login_screen.dart';

class SplashController {
  final StorageService _storageService = StorageService();

  Future<void> handleFirstLaunch(BuildContext context) async {
    await _storageService.setFirstLaunchFalse();
    getIt<AppRouter>().pushReplacement(const LoginScreen());
  }

  Future<bool> checkFirstLaunch() async {
    return await _storageService.isFirstLaunch();
  }
}
