import 'package:flutter/material.dart';
import 'package:visible/screens/admin/bottom_navigation.dart';
import 'package:visible/screens/admin/campaign/campain_page.dart';
import 'package:visible/screens/admin/dashboard.dart';
import 'package:visible/screens/admin/products_upload_page.dart';
import 'package:visible/screens/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Pages to show based on selected tab
  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminCampaignPage(),
    const AdminProductsPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
