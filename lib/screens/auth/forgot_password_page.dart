import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_emailController.text.isNotEmpty) {
      setState(() {
        _isEmailSent = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        Get.back();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
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
                        'Forgot Password',
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
                        'Enter your email to receive a password reset link',
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
          ),

          if (!_isEmailSent)
            Column(
              children: [
                // Email field with animation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 600.ms).slideX(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutQuad),

                const SizedBox(height: 28),

                // Send Reset Link Button with animation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _sendResetLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: AppColors.pureWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Send Reset Link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.easeOut),
              ],
            )
          else
            // Success message with animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reset Link Sent!',
                      style: TextStyle(
                        fontFamily: 'Leotaro',
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ve sent a password reset link to ${_emailController.text}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'TT Hoves Pro Trial',
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 400.ms),

          const SizedBox(height: 20),

          // Return to login
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Text(
              'Return to Login',
              style: TextStyle(
                fontFamily: 'TT Hoves Pro Trial',
                color: AppColors.accentOrange,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).animate(delay: 600.ms).fadeIn(duration: 600.ms).moveY(
              begin: 10, end: 0, duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
