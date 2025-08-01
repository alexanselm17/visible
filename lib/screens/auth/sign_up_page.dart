import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/model/auth/location_search.dart';
import 'package:visible/screens/auth/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const routeName = '/signup';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _hasReferralCode = false;

  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _countyController = TextEditingController();
  final _townController = TextEditingController();
  final _estateController = TextEditingController();
  final _referralCodeController = TextEditingController();
  final _countySearchController = TextEditingController();

  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  String? _selectedGender;
  String? _selectedOccupation;

  // Location data
  List<Datum> _counties = [];
  List<Datum> _filteredCounties = [];
  List<SubCounty> _subCounties = [];
  Datum? _selectedCounty;

  SubCounty? _selectedSubCounty;
  bool _isLoadingCounties = false;
  bool _showCountyDropdown = false;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialCounties();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    _countySearchController.addListener(() {
      _searchTimer?.cancel();

      _searchTimer = Timer(const Duration(milliseconds: 500), () {
        if (_countySearchController.text.isNotEmpty) {
          _searchCounties(_countySearchController.text);
        } else {
          setState(() {
            _filteredCounties = [];
            _showCountyDropdown = false;
          });
        }
      });
    });
  }

  void _loadInitialCounties() async {
    setState(() {
      _isLoadingCounties = true;
    });

    try {
      _counties = [];
      _filteredCounties = [];
    } catch (e) {
      print('Error loading initial counties: $e');
    } finally {
      setState(() {
        _isLoadingCounties = false;
      });
    }
  }

  void _searchCounties(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoadingCounties = true;
    });

    try {
      final locationData =
          await authenticationController.getUserLocation(search: query);

      if (locationData != null) {
        setState(() {
          _counties = locationData;
          _filteredCounties = locationData;
          _showCountyDropdown = true;
        });
      }
    } catch (e) {
      print('Error searching counties: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching locations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingCounties = false;
      });
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _nameController.dispose();
    _userNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countyController.dispose();
    _townController.dispose();
    _estateController.dispose();
    _referralCodeController.dispose();
    _countySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Logo
                  Image.asset('assets/images/logo_foreground.png')
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 300.ms)
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1, 1),
                        duration: 300.ms,
                        delay: 300.ms,
                        curve: Curves.bounceOut,
                      ),

                  const Text(
                    'Create an account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  // First name
                  _buildInputField(
                    label: 'First name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 20),

                  // Second name
                  _buildInputField(
                    label: 'Second name',
                    controller: _userNameController,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 20),

                  // Phone Number
                  _buildPhoneNumberField(),

                  const SizedBox(height: 20),

                  // Email Address
                  _buildInputField(
                    label: 'Email Address',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  _buildCountySearchField(),

                  const SizedBox(height: 20),

                  // SubCounty Selector
                  _buildSubCountySelector(),

                  const SizedBox(height: 20),

                  _buildInputField(
                    label: 'Town',
                    controller: _townController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    label: 'Estate',
                    controller: _estateController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 32),

                  // Gender
                  _buildGenderSection(),

                  const SizedBox(height: 32),

                  // Occupation
                  _buildOccupationSection(),

                  const SizedBox(height: 32),

                  // Create password
                  _buildPasswordSection(),

                  const SizedBox(height: 20),

                  // Confirm password
                  _buildConfirmPasswordSection(),

                  const SizedBox(height: 32),

                  // Referral Code Section
                  _buildReferralCodeSection(),

                  const SizedBox(height: 32),

                  // Terms checkbox
                  _buildTermsSection(),

                  const SizedBox(height: 32),

                  // Create Account button
                  _buildCreateAccountButton(),

                  const SizedBox(height: 24),

                  // Sign In link
                  _buildSignInLink(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
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
        const SizedBox(height: 8),
        Text(
          'Kindly note that this phone number will be used to make payments\nfor any P2P Campaigns you will have participated in.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[850]!, Colors.grey[800]!],
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
            controller: _phoneNumberController,
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
              TextInputFormatter.withFunction((oldValue, newValue) {
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
                  selection: TextSelection.collapsed(offset: buffer.length),
                );
              }),
            ],
            decoration: InputDecoration(
              prefixIcon: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[700]!.withOpacity(0.5),
                  border: Border(
                    right: BorderSide(
                      color: Colors.grey[500]!.withOpacity(0.4),
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
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
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
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildCountySearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'County',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start typing to search for your county',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[850]!, Colors.grey[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
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
          child: Column(
            children: [
              TextFormField(
                controller: _countySearchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  hintText:
                      _selectedCounty?.name ?? 'Search for your county...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                  ),
                  suffixIcon: _isLoadingCounties
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[400]!),
                          ),
                        )
                      : _selectedCounty != null
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[400]),
                              onPressed: () {
                                setState(() {
                                  _selectedCounty = null;
                                  _selectedSubCounty = null;
                                  _subCounties = [];
                                  _countySearchController.clear();
                                  _showCountyDropdown = false;
                                });
                              },
                            )
                          : null,
                ),
              ),
              // Dropdown results
              if (_showCountyDropdown && _filteredCounties.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[600]!.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredCounties.length,
                    itemBuilder: (context, index) {
                      final county = _filteredCounties[index];
                      return ListTile(
                        title: Text(
                          county.name ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Code: ${county.code}',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCounty = county;
                            _selectedSubCounty = null;
                            _subCounties = county.subCounties ?? [];
                            _countySearchController.text = county.name ?? '';
                            _showCountyDropdown = false;
                          });
                        },
                        hoverColor: Colors.grey[700],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildSubCountySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sub County',
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
              colors: [Colors.grey[850]!, Colors.grey[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
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
          child: DropdownButtonFormField<SubCounty>(
            value: _selectedSubCounty,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: _selectedCounty == null
                  ? 'Select county first'
                  : 'Select your sub county',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(
                Icons.location_on,
                color: Colors.grey[400],
              ),
            ),
            items: _subCounties.map((subCounty) {
              return DropdownMenuItem<SubCounty>(
                value: subCounty,
                child: Text(
                  subCounty.name ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: _selectedCounty == null
                ? null
                : (SubCounty? newValue) {
                    setState(() {
                      _selectedSubCounty = newValue;
                    });
                  },
          ),
        ),
      ],
    ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton('Male'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenderButton('Female'),
            ),
          ],
        ),
      ],
    ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildOccupationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Occupation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildOccupationButton('Student')),
            const SizedBox(width: 12),
            Expanded(child: _buildOccupationButton('Employed')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOccupationButton('Self Employed')),
            const SizedBox(width: 12),
            Expanded(child: _buildOccupationButton('Unemployed')),
          ],
        ),
      ],
    ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a strong password to secure your account.\nUse at least 8 characters with uppercase, lowercase, and numbers.',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[850]!, Colors.grey[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[600]!.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildConfirmPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm password',
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
              colors: [Colors.grey[850]!, Colors.grey[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[600]!.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildReferralCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _hasReferralCode,
              onChanged: (value) {
                setState(() {
                  _hasReferralCode = value ?? false;
                  if (!_hasReferralCode) {
                    _referralCodeController.clear();
                  }
                });
              },
              checkColor: Colors.black,
              fillColor: WidgetStateProperty.all(Colors.white),
              side: const BorderSide(color: Colors.white),
            ),
            const Text(
              'I have a referral code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (_hasReferralCode) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[850]!, Colors.grey[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: _referralCodeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: 'Enter referral code',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon:
                    const Icon(Icons.card_giftcard, color: Colors.orange),
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.3),
        ],
      ],
    ).animate(delay: 1050.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildTermsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          checkColor: Colors.black,
          fillColor: WidgetStateProperty.all(Colors.white),
          side: const BorderSide(color: Colors.white),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                children: [
                  const TextSpan(
                      text: 'By creating an account, I agree to the '),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: const TextStyle(
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' of Service and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Colors.orange,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 1100.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (!_acceptTerms) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please accept the Terms and Privacy Policy'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if (_selectedCounty == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select your county'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if (_selectedSubCounty == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select your sub county'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if (_townController.text == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select your town'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          if (_estateController.text == '') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select your estate'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (_hasReferralCode == '' || !_hasReferralCode) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please input referral code'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          await authenticationController.handleSignUp(
            gender: _selectedGender ?? '',
            fullname: _nameController.text,
            username: _userNameController.text,
            phone: _phoneNumberController.text,
            password: _passwordController.text,
            cpassword: _confirmPasswordController.text,
            email: _emailController.text,
            occupation: _selectedOccupation ?? '',
            county: _selectedCounty?.id ?? '',
            town: _townController.text,
            estate: _estateController.text,
            code: _hasReferralCode ? _referralCodeController.text : '',
            subCounty: _selectedSubCounty!.id!,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ).animate(delay: 1200.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildSignInLink() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        children: [
          const TextSpan(text: 'Already have an account? '),
          TextSpan(
            text: 'Sign In',
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Get.to(() => const LoginPage());
              },
          ),
        ],
      ),
    ).animate(delay: 1300.ms).fadeIn();
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[850]!, Colors.grey[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
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
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: _getIconForField(label),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _getIconForField(String label) {
    switch (label.toLowerCase()) {
      case 'first name':
      case 'second name':
        return Icon(Icons.person_outline, color: Colors.grey[400]);
      case 'email address':
        return Icon(Icons.email_outlined, color: Colors.grey[400]);
      case 'national identification number':
        return Icon(Icons.badge_outlined, color: Colors.grey[400]);
      case 'location/area':
        return Icon(Icons.location_on_outlined, color: Colors.grey[400]);
      case 'town':
        return Icon(Icons.location_city_outlined, color: Colors.grey[400]);
      case 'estate':
        return Icon(Icons.home_outlined, color: Colors.grey[400]);
      default:
        return null;
    }
  }

  Widget _buildGenderButton(String gender) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[600]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                gender == 'Male' ? Icons.male : Icons.female,
                color: isSelected ? Colors.black : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                gender,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccupationButton(String occupation) {
    bool isSelected = _selectedOccupation == occupation;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOccupation = occupation;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[600]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getOccupationIcon(occupation),
                color: isSelected ? Colors.black : Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  occupation,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getOccupationIcon(String occupation) {
    switch (occupation.toLowerCase()) {
      case 'student':
        return Icons.school;
      case 'employed':
        return Icons.work;
      case 'self employed':
        return Icons.business;
      case 'unemployed':
        return Icons.person_search;
      default:
        return Icons.work;
    }
  }
}
