import 'package:flutter/material.dart';
import 'package:visible/screens/user/bottom_navigation.dart';
import 'package:visible/screens/user/dashboard_page.dart';
import 'package:visible/screens/user/products/products_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Pages to show based on selected tab
  final List<Widget> _pages = [
    const UserDashboardPage(),
    const ProductsPage(),
    // const ProfilePage(),
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
