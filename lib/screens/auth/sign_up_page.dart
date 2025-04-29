import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/screens/auth/login_page.dart';
import 'package:visible/widgets/custom_input_decoration.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const routeName = '/signup';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Form controllers and state variables
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  // Form field validation statuses
  bool _nameValid = true;
  bool _userNameValid = true;

  bool _emailValid = true;
  final bool _passwordValid = true;
  final bool _confirmPasswordValid = true;

  String? _selectedGender;
  String? _selectedOccupation;

  // Page controller for multi-step form
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  _validateAndSubmit() {
    setState(() {
      _nameValid = _nameController.text.trim().isNotEmpty;
      _userNameValid = _userNameController.text.trim().isNotEmpty;

      _emailValid = _validateEmail(_emailController.text.trim());
    });

    if (!_nameValid && !_userNameValid && !_emailValid) {
      return CommonUtils.showErrorToast(
          'Name and Email are missing or invalid.');
    } else if (!_nameValid) {
      return CommonUtils.showErrorToast('Name is required.');
    } else if (!_emailValid) {
      return CommonUtils.showErrorToast('Enter a valid Email address.');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Stack(
        children: [
          // Background gradient
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              height: 300,
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
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(3, 3),
                end: const Offset(1, 1),
                duration: 400.ms),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // App logo and heading with animation
                    Column(
                      children: [
                        // Back button
                        _currentPage != 0
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.7),
                                    radius: 20,
                                    child: IconButton(
                                        icon: const Icon(Icons.arrow_back,
                                            color: AppColors.primaryBlack),
                                        onPressed: () {
                                          _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        }),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 300.ms)
                            : const SizedBox(),

                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
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
                        )
                            .animate()
                            .fadeIn(duration: 300.ms, delay: 300.ms)
                            .scale(
                                begin: const Offset(0.6, 0.6),
                                end: const Offset(1, 1),
                                duration: 600.ms,
                                delay: 300.ms,
                                curve: Curves.elasticOut),

                        // Heading
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontFamily: 'Leotaro',
                              color: AppColors.primaryBlack,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
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

                        // Progress indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _totalPages,
                              (index) => Container(
                                width: _currentPage == index ? 30 : 20,
                                height: 4,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.accentOrange
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                      ],
                    ),

                    // Multi-step form
                    SizedBox(
                      height: _currentPage == 0
                          ? MediaQuery.of(context).size.height * 0.95
                          : _currentPage == 1
                              ? MediaQuery.of(context).size.height * 0.65
                              : MediaQuery.of(context).size.height * 0.85,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          // Page 1: Basic Information
                          _buildPersonalInfoPage(),

                          // Page 2: Demographics
                          _buildDemographicsPage(),

                          // Page 3: Create Password
                          _buildPasswordPage(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 1: Personal Information
  Widget _buildPersonalInfoPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          const SizedBox(height: 24),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Full Name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_nameValid ? Colors.red : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                  ),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideX(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_nameValid ? Colors.red : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your user name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                  ),
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideX(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 16),

          KenyaPhoneFormField(
            label: "Phone Number",
            controller: _phoneNumberController,
            helperText: "",
          ),

          // Email field with animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Address',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_emailValid ? Colors.red : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.grey),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideX(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 16),

          // Location field with animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: 'City, Country',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: Colors.grey),
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideX(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const Spacer(),

          // Next button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _validateAndSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: AppColors.pureWhite,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDemographicsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          const SizedBox(height: 24),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gender',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Male';
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Male'
                              ? AppColors.accentOrange.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedGender == 'Male'
                                ? AppColors.accentOrange
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: _selectedGender == 'Male'
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.accentOrange.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.male_rounded,
                              color: _selectedGender == 'Male'
                                  ? AppColors.accentOrange
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Male',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _selectedGender == 'Male'
                                    ? AppColors.accentOrange
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Female';
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Female'
                              ? AppColors.accentOrange.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedGender == 'Female'
                                ? AppColors.accentOrange
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: _selectedGender == 'Female'
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.accentOrange.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.female_rounded,
                              color: _selectedGender == 'Female'
                                  ? AppColors.accentOrange
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Female',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _selectedGender == 'Female'
                                    ? AppColors.accentOrange
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 24),

          // Occupation with animation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Occupation',
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSelectionChip(
                      label: 'Student',
                      isSelected: _selectedOccupation == 'Student',
                      onTap: () {
                        setState(() {
                          _selectedOccupation = 'Student';
                        });
                      },
                    ),
                    _buildSelectionChip(
                      label: 'Employed',
                      isSelected: _selectedOccupation == 'Employed',
                      onTap: () {
                        setState(() {
                          _selectedOccupation = 'Employed';
                        });
                      },
                    ),
                    _buildSelectionChip(
                      label: 'Self-employed',
                      isSelected: _selectedOccupation == 'Self-employed',
                      onTap: () {
                        setState(() {
                          _selectedOccupation = 'Self-employed';
                        });
                      },
                    ),
                    _buildSelectionChip(
                      label: 'Unemployed',
                      isSelected: _selectedOccupation == 'Unemployed',
                      onTap: () {
                        setState(() {
                          _selectedOccupation = 'Unemployed';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const Spacer(),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                // Back button
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Next button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: AppColors.pureWhite,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  // Page 3: Password
  Widget _buildPasswordPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Page heading
          const Text(
            'Set up your password',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
            ),
          ).animate().fadeIn(duration: 300.ms).moveX(begin: -20, end: 0),

          const SizedBox(height: 8),

          Text(
            'Create a strong password to secure your account',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: 24),

          // Password field with animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_passwordValid ? Colors.red : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Create password',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    errorText: !_passwordValid
                        ? 'Password must be at least 8 characters'
                        : null,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '• Use at least 8 characters with uppercase, lowercase, and numbers',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideX(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 16),

          // Confirm Password field with animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Password',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_confirmPasswordValid
                        ? Colors.red
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm password',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    errorText: !_confirmPasswordValid
                        ? 'Passwords do not match'
                        : null,
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideX(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 24),

          // Terms and Conditions with animation
          Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: _acceptTerms,
                    activeColor: AppColors.accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                            text: 'By creating an account, I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Open Terms of Service
                              debugPrint('Terms of Service tapped');
                            },
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Open Privacy Policy
                              debugPrint('Privacy Policy tapped');
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).moveY(
              begin: 10, end: 0, duration: 400.ms, curve: Curves.easeOut),

          const Spacer(),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                // Back button
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Create account button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_acceptTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Please accept the Terms and Privacy Policy'),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(12),
                            ),
                          );
                        }
                        authenticationController.handleSignUp(
                          gender: _selectedGender!,
                          fullname: _nameController.text,
                          username: _userNameController.text,
                          phone: _phoneNumberController.text,
                          password: _passwordController.text,
                          cpassword: _confirmPasswordController.text,
                          email: _emailController.text,
                          occupation: _selectedOccupation!,
                          location: _locationController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: AppColors.pureWhite,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

          // Already have an account link
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign in',
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to login screen
                          Get.to(() => const LoginPage());
                        },
                    ),
                  ],
                ),
              ),
            ),
          ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  // Helper widget for selection chips (occupation)
  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.accentOrange : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // Success dialog with animation
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon with animation
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.accentOrange,
                    size: 60,
                  ),
                ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 24),

                // Success message with animation
                const Text(
                  'Account Created Successfully!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 16),

                Text(
                  'Your account has been created successfully. You can now log in with your credentials.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to login screen
                      Get.offAll(() => const LoginPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: AppColors.pureWhite,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue to Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}
