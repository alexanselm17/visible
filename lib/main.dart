import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visible/constants/app_theme.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/screens/auth/login_page.dart';
import 'package:visible/screens/auth/onboarding_page.dart';
import 'package:visible/service/notification/pushNotification.dart';
import 'package:visible/service/notification/service_locator.dart';
import 'package:visible/screens/user/main_screen.dart' as user;
import 'package:visible/screens/admin/main_screen.dart' as admin;
import 'package:visible/shared_preferences/user_pref.dart';
import 'package:visible/widgets/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  await Firebase.initializeApp();
  try {
    setupLocator();
    PushNotification().initialize();
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Visible App',
      theme: AppTheme.lightTheme,
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _determineInitialRoute();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _determineInitialRoute() async {
    final userPrefs = UserPreferences();
    await Future.delayed(const Duration(milliseconds: 300));

    final introShown = await userPrefs.isIntroScreenShown();
    final token = await userPrefs.getToken();

    if (!introShown) {
      _navigateToPage(const OnboardingScreen());
      return;
    }

    if (token.isEmpty) {
      _navigateToPage(const LoginPage());
      return;
    }

    final signInModel = await userPrefs.getSignInModel();
    final slug = signInModel?.data?.role?.slug;
    print('User role: $slug');

    if (slug == 'admin') {
      _navigateToPage(const admin.MainScreen());
    } else {
      _navigateToPage(const user.MainScreen());
    }
  }

  void _navigateToPage(Widget page) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Get.offAll(() => page);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'An error occurred',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: AnimatedLoadingIndicator(
                  isLoading: true,
                  primaryColor: AppColors.accentOrange,
                  secondaryColor: Colors.white,
                  size: 50,
                  loadingText: 'Loading dashboard...',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/1.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            const Center(
              child: AnimatedLoadingIndicator(
                isLoading: true,
                primaryColor: AppColors.accentOrange,
                secondaryColor: Colors.white,
                size: 50,
                loadingText: 'Loading dashboard...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
