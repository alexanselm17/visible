import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/screens/auth/forgot_password_page.dart';
import 'package:visible/screens/auth/sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Container(
                width: 160,
                height: 160,
                margin: const EdgeInsets.only(bottom: 60),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'Visible.',
                    style: TextStyle(
                      fontFamily: 'Leotaro',
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 300.ms).scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  delay: 300.ms,
                  curve: Curves.bounceOut),

              // Form Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username/Email Field
                    const Text(
                      'Username Or Email',
                      style: TextStyle(
                        fontFamily: 'TT Hoves Pro Trial',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    )
                        .animate(delay: const Duration(milliseconds: 300))
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontFamily: 'TT Hoves Pro Trial',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                    )
                        .animate(delay: const Duration(milliseconds: 400))
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Remember me and Forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.accentOrange,
                                checkColor: Colors.white,
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.disabled)) {
                                      return null;
                                    }
                                    if (states.contains(WidgetState.selected)) {
                                      return AppColors.accentOrange;
                                    }
                                    return Colors.transparent;
                                  },
                                ),
                                side: const BorderSide(
                                    color: Colors.white, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Remember me',
                              style: TextStyle(
                                fontFamily: 'TT Hoves Pro Trial',
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(const ForgotPasswordPage());
                            debugPrint('Forgot password tapped');
                          },
                          child: const Text(
                            'Forgot Password',
                            style: TextStyle(
                              fontFamily: 'TT Hoves Pro Trial',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate(delay: const Duration(milliseconds: 450))
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, duration: 400.ms),

                    const SizedBox(height: 40),

                    // Sign In Button
                    Obx(
                      () => authenticationController.isLoggingIn.value
                          ? Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accentOrange,
                                  strokeWidth: 3,
                                ),
                              ),
                            ).animate().fadeIn(duration: 300.ms)
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await authenticationController.handleSignIn(
                                      userName: _emailController.text,
                                      password: _passwordController.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'TT Hoves Pro Trial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                              .animate(delay: const Duration(milliseconds: 500))
                              .fadeIn(duration: 600.ms)
                              .moveY(begin: 10, end: 0, duration: 400.ms),
                    ),

                    const SizedBox(height: 40),

                    // Sign Up Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'TT Hoves Pro Trial',
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Sign Up.',
                              style: const TextStyle(
                                color: AppColors.accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(const SignUpPage());
                                },
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: const Duration(milliseconds: 600))
                        .fadeIn(duration: 600.ms)
                        .moveY(begin: 10, end: 0, duration: 400.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
