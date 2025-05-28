import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  final AuthenticationController _authenticationController =
      Get.put(AuthenticationController());

  @override
  void initState() {
    _authenticationController.loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Obx(
          () {
            final user = _authenticationController.currentUser.value;
            final displayName = (user.fullname?.isNotEmpty == true)
                ? user.fullname
                : user.username ?? 'User';
            final email = user.email ?? 'No email provided';
            final phone = user.phone ?? 'No phone provided';
            final location = user.location ?? 'No location provided';
            final occupation = user.occupation ?? 'Not specified';
            final gender = user.gender ?? 'Not specified';

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
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
                            Text(
                              displayName!,
                              style: const TextStyle(
                                fontFamily: 'Leotaro',
                                color: AppColors.primaryBlack,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                            const SizedBox(height: 8),
                            Text(
                              email,
                              style: const TextStyle(
                                fontFamily: 'TT Hoves Pro Trial',
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
                            const SizedBox(height: 16),
                            if (user.occupation != null)
                              Text(
                                occupation,
                                style: const TextStyle(
                                  fontFamily: 'TT Hoves Pro Trial',
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 380.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                                phone,
                                500.ms,
                              ),
                              const Divider(
                                  height: 1, thickness: 1, indent: 56),
                              _buildInfoItem(
                                Icons.location_on,
                                'Location',
                                location,
                                550.ms,
                              ),
                              if (user.gender != null) ...[
                                const Divider(
                                    height: 1, thickness: 1, indent: 56),
                                _buildInfoItem(
                                  Icons.person,
                                  'Gender',
                                  gender,
                                  600.ms,
                                ),
                              ],
                              if (user.nationalId != null) ...[
                                const Divider(
                                    height: 1, thickness: 1, indent: 56),
                                _buildInfoItem(
                                  Icons.badge,
                                  'National ID',
                                  user.nationalId.toString(),
                                  650.ms,
                                ),
                              ],
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                        const SizedBox(height: 30),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'Leotaro',
                            color: AppColors.primaryBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
                        const SizedBox(height: 16),
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
                                750.ms,
                              ),
                              const Divider(
                                  height: 1, thickness: 1, indent: 56),
                              _buildSettingItem(
                                Icons.dark_mode,
                                'Dark Mode',
                                _darkModeEnabled,
                                (value) {
                                  setState(() {
                                    _darkModeEnabled = value;
                                  });
                                },
                                800.ms,
                              ),
                              const Divider(
                                  height: 1, thickness: 1, indent: 56),
                              _buildSettingItem(
                                Icons.location_on,
                                'Location Services',
                                _locationEnabled,
                                (value) {
                                  setState(() {
                                    _locationEnabled = value;
                                  });
                                },
                                850.ms,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 750.ms),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _authenticationController.logOut();
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
                        ).animate(delay: 900.ms).fadeIn(duration: 400.ms).scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1, 1),
                            duration: 400.ms,
                            curve: Curves.easeOut),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
          Expanded(
            child: Column(
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
