import 'package:flutter/material.dart';

class MainBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<MainBottomNavigation> createState() => _MainBottomNavigationState();
}

class _MainBottomNavigationState extends State<MainBottomNavigation> {
  // Define black and white colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color selectedBlack = Color(0xFF000000);
  static const Color unselectedGray = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    // Force black background for visibility
    const backgroundColor = primaryBlack;
    const selectedItemColor = pureWhite;
    const unselectedItemColor =
        Color(0xFFBBBBBB); // Lighter gray for better visibility on black

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.white
                .withOpacity(0.1), // Light shadow on black background
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: widget.onTap,
              backgroundColor: backgroundColor,
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: pureWhite, // Ensure white text for visibility
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 11,
                color: Color(0xFFBBBBBB), // Light gray for unselected labels
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  selectedItemColor: selectedItemColor,
                ),
                _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag,
                  label: 'campaigns',
                  selectedItemColor: selectedItemColor,
                ),
                // _buildNavItem(
                //   icon: Icons.person_outline_rounded,
                //   activeIcon: Icons.person,
                //   label: 'Profile',
                //   selectedItemColor: selectedItemColor,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color selectedItemColor,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: pureWhite.withOpacity(
              0.2), // Semi-transparent white background for better visibility
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: pureWhite.withOpacity(0.3), // Subtle white border
            width: 1,
          ),
        ),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}
