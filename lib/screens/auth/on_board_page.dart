import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/screens/auth/login_page.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with TickerProviderStateMixin {
  // Define your custom colors

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
                      AppColors.primaryBlack,
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
                              fit: BoxFit
                                  .cover, // Keeps image ratio, fills container
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
                            const EdgeInsetsDirectional.fromSTEB(0, 44, 0, 0),
                        child: const Text(
                          'Welcome!',
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
                          'Thanks for joining! Access or create your account below, and get started on your journey!',
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
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 44),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 16),
                        child: ElevatedButton(
                          onPressed: () {
                            debugPrint('Get Started button pressed');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlack,
                            backgroundColor: AppColors.pureWhite,
                            minimumSize: const Size(230, 52),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: AppColors.primaryBlack,
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontFamily: 'TT Hoves Pro Trial',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 16),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(const LoginPage());
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.pureWhite,
                            backgroundColor: AppColors.accentOrange,
                            minimumSize: const Size(230, 52),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'My Account',
                            style: TextStyle(
                              fontFamily: 'TT Hoves Pro Trial',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms).scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  delay: 300.ms,
                  curve: Curves.bounceOut),
            ),
          ],
        ),
      ),
    );
  }
}
