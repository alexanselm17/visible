import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/screens/auth/forgot_password_page.dart';
import 'package:visible/screens/auth/sign_up_page.dart';
import 'package:visible/widgets/input_widgets.dart';

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
      backgroundColor: AppColors.pureWhite,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header with gradient and logo
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkBlue,
                    AppColors.accentOrange,
                    AppColors.primaryBlack
                  ],
                  stops: [0, 0.5, 1],
                  begin: AlignmentDirectional(-1, -1),
                  end: AlignmentDirectional(1, 1),
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x00FFFFFF), AppColors.pureWhite],
                    stops: [0, 1],
                    begin: AlignmentDirectional(0, -1),
                    end: AlignmentDirectional(0, 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xCCFFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo_foreground.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1, 1),
                        duration: 300.ms,
                        delay: 300.ms,
                        curve: Curves.bounceOut),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 40, 0, 0),
                      child: const Text(
                        'Sign In!',
                        style: TextStyle(
                          fontFamily: 'Leotaro',
                          color: AppColors.primaryBlack,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 350.ms).moveY(
                          begin: 30, end: 0, duration: 400.ms, delay: 350.ms),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0),
                      child: const Text(
                        'Use the account below to sign in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'TT Hoves Pro Trial',
                          color: AppColors.primaryBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 400.ms).moveY(
                          begin: 30, end: 0, duration: 400.ms, delay: 400.ms),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(3, 3),
                end: const Offset(1, 1),
                duration: 400.ms),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  StandardFormField(
                    label: 'Username',
                    hintText: 'Enter your username',
                    controller: _emailController,
                    prefixIconData: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    animationDelay: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 20),
                  PasswordFormField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    animationDelay: const Duration(milliseconds: 400),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.accentOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
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
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ],
                        ),

                        // Forgot password link
                        GestureDetector(
                          onTap: () {
                            Get.to(const ForgotPasswordPage());
                            debugPrint('Forgot password tapped');
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontFamily: 'TT Hoves Pro Trial',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(delay: const Duration(milliseconds: 450))
                      .fadeIn(duration: 600.ms)
                      .moveY(
                          begin: 10,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut),
                  const SizedBox(height: 40),
                  Obx(
                    () => authenticationController.isLoggingIn.value
                        ? Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.darkBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentOrange,
                                strokeWidth: 3,
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms)
                        : FormActionButton(
                            text: 'Sign In',
                            onPressed: () async {
                              await authenticationController.handleSignIn(
                                  userName: _emailController.text,
                                  password: _passwordController.text);
                            },
                            animationDelay: const Duration(milliseconds: 500),
                          ),
                  ),
                  const SizedBox(height: 30),
                  AuthLinkText(
                    leadText: "Don't have an account?",
                    linkText: 'Sign up',
                    onTap: () {
                      Get.to(const SignUpPage());
                    },
                    animationDelay: const Duration(milliseconds: 600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
