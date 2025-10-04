import 'package:flutter/material.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/routes/app_routes.dart';

class SplashController {
  final StorageService _storageService = StorageService();

  Future<void> handleFirstLaunch(BuildContext context) async {
    await _storageService.setFirstLaunchFalse();
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<bool> checkFirstLaunch() async {
    return await _storageService.isFirstLaunch();
  }
}
