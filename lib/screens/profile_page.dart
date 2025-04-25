import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/screens/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data
  final String _userName = "Alex Mulwa";
  final String _userEmail = "alex.mulwa@example.com";
  final String _userPhone = "+254 (7101) 294-13";
  final String _userLocation = "Juja , Kenya";
  final String _userBio =
      "UI/UX Designer with 5+ years of experience. Passionate about creating beautiful and functional mobile experiences.";

  // Settings toggles
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   title: const Text(
        //     'Profile',
        //     style: TextStyle(
        //       fontFamily: 'Leotaro',
        //       color: AppColors.primaryBlack,
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   centerTitle: true,
        //   leading: null,
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header with gradient background
              SizedBox(
                width: double.infinity,
                // decoration: const BoxDecoration(
                //   gradient: LinearGradient(
                //     colors: [
                //       AppColors.darkBlue,
                //       AppColors.accentOrange,
                //     ],
                //     begin: AlignmentDirectional(-1, -1),
                //     end: AlignmentDirectional(1, 1),
                //   ),
                // ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x00FFFFFF), AppColors.pureWhite],
                      stops: [0.7, 1],
                      begin: AlignmentDirectional(0, -1),
                      end: AlignmentDirectional(0, 1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 60),
                    child: Column(
                      children: [
                        // Profile image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xCCFFFFFF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.pureWhite,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/profile_placeholder.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primaryBlack,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1, 1),
                                duration: 400.ms,
                                curve: Curves.easeOut),

                        const SizedBox(height: 16),

                        // User name
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontFamily: 'Leotaro',
                            color: AppColors.primaryBlack,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                        const SizedBox(height: 8),

                        // User email
                        Text(
                          _userEmail,
                          style: const TextStyle(
                            fontFamily: 'TT Hoves Pro Trial',
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                        const SizedBox(height: 16),

                        // User bio
                        Text(
                          _userBio,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'TT Hoves Pro Trial',
                            color: AppColors.primaryBlack,
                            fontSize: 14,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),

              // Personal Information Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontFamily: 'Leotaro',
                        color: AppColors.primaryBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoItem(
                            Icons.phone,
                            'Phone',
                            _userPhone,
                            500.ms,
                          ),
                          const Divider(height: 1, thickness: 1, indent: 56),
                          _buildInfoItem(
                            Icons.location_on,
                            'Location',
                            _userLocation,
                            550.ms,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                    const SizedBox(height: 30),

                    // Settings Section
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'Leotaro',
                        color: AppColors.primaryBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                    const SizedBox(height: 16),

                    // Settings card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(
                            Icons.notifications,
                            'Notifications',
                            _notificationsEnabled,
                            (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                            650.ms,
                          ),
                          const Divider(height: 1, thickness: 1, indent: 56),
                          _buildSettingItem(
                            Icons.dark_mode,
                            'Dark Mode',
                            _darkModeEnabled,
                            (value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                            },
                            700.ms,
                          ),
                          const Divider(height: 1, thickness: 1, indent: 56),
                          _buildSettingItem(
                            Icons.location_on,
                            'Location Services',
                            _locationEnabled,
                            (value) {
                              setState(() {
                                _locationEnabled = value;
                              });
                            },
                            750.ms,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                    const SizedBox(height: 30),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAll(const LoginPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pureWhite,
                          foregroundColor: AppColors.accentOrange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: AppColors.accentOrange,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).animate(delay: 800.ms).fadeIn(duration: 400.ms).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOut),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String title, String value, Duration delay) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.accentOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'TT Hoves Pro Trial',
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'TT Hoves Pro Trial',
                  color: AppColors.primaryBlack,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay);
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
    Duration delay,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accentOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'TT Hoves Pro Trial',
                  color: AppColors.primaryBlack,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentOrange,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay);
  }
}
