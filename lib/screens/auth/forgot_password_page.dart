import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const routeName = '/forgot-password';

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _emailController = TextEditingController();

  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_usernameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _nationalIdController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordConfirmationController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return;
    }

    if (_passwordController.text != _passwordConfirmationController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authenticationController.resetPassword(
        username: _usernameController.text,
        phone: _phoneController.text,
        nationalId: _nationalIdController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
        email: _emailController.text,
      );

      setState(() {
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 3), () {
        Get.back();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Failed to reset password. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade700,
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Obx(
        () => Column(
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
                          'Reset Password',
                          style: TextStyle(
                            fontFamily: 'Leotaro',
                            color: AppColors.primaryBlack,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 350.ms)
                            .moveY(
                                begin: 30,
                                end: 0,
                                duration: 400.ms,
                                delay: 350.ms),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0),
                        child: const Text(
                          'Enter your details to reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'TT Hoves Pro Trial',
                            color: AppColors.primaryBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms)
                            .moveY(
                                begin: 30,
                                end: 0,
                                duration: 400.ms,
                                delay: 400.ms),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(3, 3),
                  end: const Offset(1, 1),
                  duration: 400.ms),
            ),

            if (!authenticationController.isPasswordReset.value)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Username field
                        _buildTextField(
                          controller: _usernameController,
                          hintText: 'Username',
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 600.ms,
                                curve: Curves.easeOutQuad),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 600.ms,
                                curve: Curves.easeOutQuad),

                        // Phone field
                        _buildTextField(
                          controller: _phoneController,
                          hintText: 'Phone Number',
                          keyboardType: TextInputType.phone,
                        )
                            .animate(delay: 350.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 600.ms,
                                curve: Curves.easeOutQuad),

                        // National ID field
                        _buildTextField(
                          controller: _nationalIdController,
                          hintText: 'National ID',
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 600.ms,
                                curve: Curves.easeOutQuad),

                        // New Password field
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'New Password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        )
                            .animate(delay: 450.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 600.ms,
                                curve: Curves.easeOutQuad),

                        // Confirm Password field
                        _buildTextField(
                          controller: _passwordConfirmationController,
                          hintText: 'Confirm New Password',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(
                                begin: 0.2,
                                end: 0,
                                duration: 600.ms,
                                curve: Curves.easeOutQuad),

                        const SizedBox(height: 12),

                        // Reset Password Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: AppColors.pureWhite,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.pureWhite,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ).animate(delay: 550.ms).fadeIn(duration: 600.ms).scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.easeOut),
                      ],
                    ),
                  ),
                ),
              )
            else
              // Success message
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
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Password Reset Successfully!',
                        style: TextStyle(
                          fontFamily: 'Leotaro',
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your password has been reset successfully. You can now login with your new password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
      ),
    );
  }
}
