import 'dart:developer';
import 'package:chatup/core/utils/ui_utils.dart';
import 'package:chatup/data/services/service_locator.dart';
import 'package:chatup/logic/cubits/auth/auth_cubit.dart';
import 'package:chatup/presentation/screens/auth/login_screen.dart';
import 'package:chatup/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:chatup/core/common/custom_button.dart';
import 'package:chatup/core/common/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/cubits/auth/auth_state.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _nameFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = true;
  bool _isLoading = false;

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
    _nameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if ((value == null) || (value.isEmpty)) {
      return "Please enter your name";
    }

    return null;
  }

  String? _validateUsername(String? value) {
    if ((value == null) || (value.isEmpty)) {
      return "Please enter a username";
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if ((value == null) || (value.isEmpty)) {
      return "Please enter your email";
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email";
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if ((value == null) || (value.isEmpty)) {
      return "Please enter your phone number";
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return "Please enter a valid number";
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value == null) || (value.isEmpty)) {
      return "Please enter a password";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  Future<void> handleSignup() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        await getIt<AuthCubit>().signup(
          fullName: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        UIiUtils.showSnackBar(context, message: e.toString(), isError: true);
      }
    } else {
      log("Form Validation Failed in Signup");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          UIiUtils.showSnackBar(
            context,
            message: "Account created successfully!",
            isError: false,
          );
          getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          setState(() {
            _isLoading = false;
          });
          UIiUtils.showSnackBar(context, message: state.error!, isError: true);
        }
      },
      builder: (context, state) {
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
                            key: _formKey,
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
                                  focusNode: _nameFocusNode,
                                  validator: _validateName,
                                  hintText: "Full Name",
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF3B9FA7),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  controller: usernameController,
                                  focusNode: _usernameFocusNode,
                                  validator: _validateUsername,
                                  hintText: "Username",
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                    color: Color(0xFF3B9FA7),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  controller: emailController,
                                  focusNode: _emailFocusNode,
                                  validator: _validateEmail,
                                  hintText: "Email",
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF3B9FA7),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                  controller: phoneController,
                                  focusNode: _phoneFocusNode,
                                  validator: _validatePhone,
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
                                  focusNode: _passwordFocusNode,
                                  validator: _validatePassword,
                                  hintText: "Password",
                                  obscureText: _isPasswordVisible,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF3B9FA7),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    icon: _isPasswordVisible
                                        ? Icon(Icons.visibility)
                                        : Icon(Icons.visibility_off),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                CustomButton(
                                  onPressed: _isLoading ? null : handleSignup,
                                  text: _isLoading
                                      ? "Creating Account..."
                                      : "Create Account",
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    getIt<AppRouter>().push(
                                      const LoginScreen(),
                                    );
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
      },
    );
  }
}
