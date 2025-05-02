import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visible/constants/app_theme.dart';
import 'package:visible/screens/auth/on_board_page.dart';
import 'package:visible/service/notification/pushNotification.dart';
import 'package:visible/service/notification/service_locator.dart';
import 'package:visible/screens/user/main_screen.dart' as user;
import 'package:visible/screens/admin/main_screen.dart' as admin;
import 'package:visible/shared_preferences/user_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  try {
    setupLocator();
    PushNotification().initialize();
    runApp(const MyApp());
  } catch (e) {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Future<Widget> _getInitialPage() async {
    final userPrefs = UserPreferences();
    final token = await userPrefs.getToken();

    if (token.isEmpty) {
      return const OnBoardingPage();
    }

    final signInModel = await userPrefs.getSignInModel();
    final slug = signInModel?.data?.role?.slug;

    if (slug == 'admin') {
      return const admin.MainScreen();
    } else {
      return const user.MainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('An error occurred')),
          );
        } else {
          return snapshot.data!;
        }
      },
    );
  }
}
