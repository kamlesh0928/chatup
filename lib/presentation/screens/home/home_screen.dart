import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/logic/cubits/auth/auth_cubit.dart';
import 'package:chatup/presentation/screens/auth/login_screen.dart';
import 'package:chatup/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () async {
              await getIt<AuthCubit>().logout();
              getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
            },
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text("Home Page")),
    );
  }
}
