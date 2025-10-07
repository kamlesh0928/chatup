import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/presentation/screens/auth/login_screen.dart';
import 'package:chatup/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final SplashController _controller = SplashController();
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 250).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
        )..addListener(() {
          setState(() {});
        });
    _animationController.forward();
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    final isFirstLaunch = await _controller.checkFirstLaunch();

    if (!isFirstLaunch) {
      getIt<AppRouter>().pushReplacement(const LoginScreen());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFECF4F4), Color(0xFFCEE6E8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: SvgPicture.asset(
                        'lib/assets/texting_illustration.svg',
                        height: _animation.value,
                        width: _animation.value,
                      ),
                    );
                  },
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Welcome to ChatUp",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B9FA7),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Connect, Communicate, and Thrive!",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _controller.handleFirstLaunch(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B9FA7),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    fixedSize: const Size(320, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    "Start Your Journey",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
