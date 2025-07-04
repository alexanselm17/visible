import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _passwordConfirmationController.text.trim(),
        email: _emailController.text.trim(),
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
                  SizedBox(
                    child: Image.asset(
                      'assets/images/logo_foreground.png',
                    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                          duration: 300.ms,
                          delay: 300.ms,
                          curve: Curves.bounceOut,
                        ),
                  ),
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Phone Number',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey[850]!,
                                    Colors.grey[800]!
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[600]!.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 11,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(9),
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    final text = newValue.text;
                                    if (text.length <= 3) return newValue;

                                    String newText = text.replaceAll(' ', '');
                                    final buffer = StringBuffer();

                                    for (int i = 0; i < newText.length; i++) {
                                      if (i == 3 || i == 6) {
                                        buffer.write(' ');
                                      }
                                      buffer.write(newText[i]);
                                    }
                                    return TextEditingValue(
                                      text: buffer.toString(),
                                      selection: TextSelection.collapsed(
                                          offset: buffer.length),
                                    );
                                  }),
                                ],
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700]!.withOpacity(0.5),
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.grey[500]!
                                              .withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Image.asset(
                                              'assets/images/Flag_of_Kenya.png',
                                              width: 28,
                                              height: 20,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "+254",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  hintText: "XXX XXX XXX",
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  counterText: "",
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                ),
                                cursorColor: Colors.blue[400],
                                cursorWidth: 2,
                              ),
                            )
                                .animate(delay: 400.ms)
                                .fadeIn(duration: 600.ms)
                                .moveY(begin: 10, end: 0, duration: 400.ms),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),

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
