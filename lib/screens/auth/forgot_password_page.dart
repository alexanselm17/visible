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
        isLoggedIn: false,
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
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (!authenticationController.isPasswordReset.value) ...[
                  // Logo Section
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        'Visible.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
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

                  // Title Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
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
                        const SizedBox(height: 6),
                        const Text(
                          'Enter your details to reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
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
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),

                  // Form Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        // Username field
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hintText: 'Enter your username',
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        )
                            .animate(delay: 350.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        // Phone field
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hintText: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        // National ID field
                        _buildTextField(
                          controller: _nationalIdController,
                          label: 'National ID',
                          hintText: 'Enter your national ID',
                        )
                            .animate(delay: 450.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        // New Password field
                        _buildTextField(
                          controller: _passwordController,
                          label: 'New Password',
                          hintText: 'Enter new password',
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        )
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        // Confirm Password field
                        _buildTextField(
                          controller: _passwordConfirmationController,
                          label: 'Confirm New Password',
                          hintText: 'Confirm new password',
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        )
                            .animate(delay: 550.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        // Reset Password Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        )
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        const SizedBox(height: 20),

                        // Return to login
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: const Text(
                            'Return to Login',
                            style: TextStyle(
                              color: AppColors.accentOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            .animate(delay: 650.ms)
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 10, end: 0, duration: 400.ms),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ] else ...[
                  // Success message section
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 400.ms),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        const Text(
                          'Password Reset Successfully!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                        const SizedBox(height: 12),

                        const Text(
                          'Your password has been reset successfully. You can now login with your new password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                        const SizedBox(height: 30),

                        // Return to login button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Return to Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ).animate(delay: 400.ms).fadeIn(duration: 600.ms).moveY(
                              begin: 10,
                              end: 0,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
