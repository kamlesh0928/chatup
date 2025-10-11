import 'package:chatup/data/repositories/chat_repository.dart';
import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/logic/cubits/auth/auth_cubit.dart';
import 'package:chatup/logic/cubits/auth/auth_state.dart';
import 'package:chatup/logic/observer/app_life_cycle_observer.dart';
import 'package:chatup/presentation/screens/auth/login_screen.dart';
import 'package:chatup/presentation/screens/home/home_screen.dart';
import 'package:chatup/presentation/screens/splash/splash_screen.dart';
import 'package:chatup/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:chatup/config/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifeCycleObserver _lifeCycleObserver;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    getIt<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        _lifeCycleObserver = AppLifeCycleObserver(
          userId: state.user!.uid,
          chatRepository: getIt<ChatRepository>(),
        );
      }

      WidgetsBinding.instance.addObserver(_lifeCycleObserver);
    });
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's first launch
    _isFirstLaunch = prefs.getBool("isFirstLaunch") ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'ChatUp',
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          bloc: getIt<AuthCubit>(),
          builder: (context, state) {
            if (_isFirstLaunch) {
              return const SplashScreen();
            }

            if (state.status == AuthStatus.initial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.status == AuthStatus.authenticated) {
              return const HomeScreen();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
