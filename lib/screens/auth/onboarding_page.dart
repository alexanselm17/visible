import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/screens/auth/login_page.dart';
import 'package:visible/shared_preferences/user_pref.dart';
import 'package:visible/widgets/input_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      icon: Icons.download_outlined,
      title: 'Download Images',
      description:
          'Browse and download high-quality images from our extensive collection for free',
      color: AppColors.accentOrange,
      animationType: AnimationType.download,
    ),
    OnboardingData(
      icon: Icons.share_outlined,
      title: 'Share on WhatsApp',
      description:
          'Post your downloaded images as WhatsApp status updates to share with friends',
      color: AppColors.darkBlue,
      animationType: AnimationType.share,
    ),
    OnboardingData(
      icon: Icons.upload_outlined,
      title: 'Upload & Earn',
      description:
          'Upload screenshots of your WhatsApp status and start earning rewards instantly',
      color: AppColors.accentOrange,
      animationType: AnimationType.upload,
    ),
    OnboardingData(
      icon: Icons.monetization_on_outlined,
      title: 'Start Earning',
      description:
          'Turn your social sharing into a rewarding experience with Visible',
      color: AppColors.primaryBlack,
      animationType: AnimationType.earn,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await UserPreferences().setIntroScreenShown(true);
      Get.offAll(() => const LoginPage());
    }
  }

  void _skipOnboarding() async {
    await UserPreferences().setIntroScreenShown(true);
    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x00FFFFFF), AppColors.pureWhite],
                stops: [0, 1],
                begin: AlignmentDirectional(0, -1),
                end: AlignmentDirectional(0, 1),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Welcome text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                        const Text(
                          'Visible',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 300.ms)
                            .moveX(
                                begin: -20,
                                end: 0,
                                duration: 400.ms,
                                delay: 300.ms),
                      ],
                    ),

                    // Skip button
                    GestureDetector(
                      onTap: _skipOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryBlack.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.primaryBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingPages.length,
              itemBuilder: (context, index) {
                final page = _onboardingPages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Icon Container
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              page.color.withOpacity(0.1),
                              page.color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page.color.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildAnimatedIcon(page),
                      )
                          .animate(delay: const Duration(milliseconds: 200))
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),

                      const SizedBox(height: 50),

                      // Title
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      )
                          .animate(delay: Duration(milliseconds: 150 * index))
                          .fadeIn(duration: 600.ms)
                          .moveY(begin: 20, end: 0, duration: 600.ms),

                      const SizedBox(height: 20),

                      // Description
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryBlack,
                          height: 1.5,
                        ),
                      )
                          .animate(delay: Duration(milliseconds: 200 * index))
                          .fadeIn(duration: 700.ms)
                          .moveY(begin: 20, end: 0, duration: 700.ms),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom section with indicators and button
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingPages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.accentOrange
                            : AppColors.accentOrange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ),
                ),

                const SizedBox(height: 40),

                // Continue/Get Started button
                FormActionButton(
                  text: _currentPage == _onboardingPages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  onPressed: _nextPage,
                  animationDelay: const Duration(milliseconds: 300),
                ),

                const SizedBox(height: 16),

                // Additional info for last page
                if (_currentPage == _onboardingPages.length - 1)
                  const Text(
                    'Join thousands of users already earning with Visible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryBlack,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(OnboardingData page) {
    switch (page.animationType) {
      case AnimationType.download:
        return Icon(
          page.icon,
          size: 70,
          color: page.color,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(
              begin: -5,
              end: 5,
              duration: 2000.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .moveY(
              begin: 5,
              end: -5,
              duration: 2000.ms,
              curve: Curves.easeInOut,
            );

      case AnimationType.share:
        return Icon(
          page.icon,
          size: 70,
          color: page.color,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(
              begin: -0.1,
              end: 0.1,
              duration: 1500.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .rotate(
              begin: 0.1,
              end: -0.1,
              duration: 1500.ms,
              curve: Curves.easeInOut,
            );

      case AnimationType.upload:
        return Icon(
          page.icon,
          size: 70,
          color: page.color,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .moveY(
              begin: 5,
              end: -5,
              duration: 1800.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .moveY(
              begin: -5,
              end: 5,
              duration: 1800.ms,
              curve: Curves.easeInOut,
            );

      case AnimationType.earn:
        return Icon(
          page.icon,
          size: 70,
          color: page.color,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1.0, 1.0),
              duration: 2000.ms,
              curve: Curves.easeInOut,
            );

      default:
        return Icon(
          page.icon,
          size: 70,
          color: page.color,
        );
    }
  }
}

enum AnimationType {
  download,
  share,
  upload,
  earn,
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final AnimationType animationType;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.animationType,
  });
}
