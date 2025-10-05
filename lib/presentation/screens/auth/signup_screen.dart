import 'package:flutter/material.dart';
import 'package:chatup/core/common/custom_button.dart';
import 'package:chatup/core/common/custom_text_field.dart';
import '../../../core/routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFECF4F4), Color(0xFFCEE6E8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: _slideAnimation.value,
                    child: Container(
                      width: 340,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Form(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 25),
                            Text(
                              "Create Account",
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Please fill in the details to continue",
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            CustomTextField(
                              controller: nameController,
                              hintText: "Full Name",
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Color(0xFF3B9FA7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: usernameController,
                              hintText: "username",
                              prefixIcon: Icon(
                                Icons.alternate_email_rounded,
                                color: Color(0xFF3B9FA7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: emailController,
                              hintText: "Email",
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Color(0xFF3B9FA7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: phoneController,
                              hintText: "Phone Number",
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: Color(0xFF3B9FA7),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: passwordController,
                              hintText: "Password",
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Color(0xFF3B9FA7),
                              ),
                              suffixIcon: Icon(
                                Icons.visibility,
                                color: Color(0xFF3B9FA7),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 25),
                            CustomButton(onPressed: () {}, text: "Create Account"),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.login);
                              },
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Already have an account? ",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                        color: Color(0xFF3B9FA7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
