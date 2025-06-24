import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/model/users/report.dart';
import 'package:visible/screens/reports/customer_report.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthenticationController _authenticationController =
      Get.put(AuthenticationController());

  bool showReport = false;
  DateTime? fromDate;
  DateTime? toDate;
  String selectedTab = 'Ongoing';
  int currentPage = 1;
  int totalPages = 10;
  bool isLoading = false;
  List<Map<String, dynamic>> campaignData = [];
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    _authenticationController.loadUserData();
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    _fetchReportData();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              brightness: Brightness.dark,
              primary: Color(0xFF4CAF50), // Green accent for selected date
              onPrimary: Colors.white,
              secondary: Color(0xFF03DAC6), // Teal accent
              onSecondary: Colors.black,
              surface: Color(0xFF1E1E1E), // Dark surface
              onSurface: Colors.white,
              error: Color(0xFFCF6679),
              onError: Colors.black,
              outline: Color(0xFF484848), // Subtle borders
              surfaceContainerHighest:
                  Color(0xFF2C2C2C), // Slightly lighter surface
              onSurfaceVariant: Color(0xFFE0E0E0),
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              titleMedium: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              bodyMedium: TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 14,
              ),
              labelLarge: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Customize dialog shape and elevation
            dialogTheme: const DialogTheme(
              backgroundColor: Color(0xFF1E1E1E),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              elevation: 8,
            ),
            // Customize buttons
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            // Customize dividers
            dividerTheme: const DividerThemeData(
              color: Color(0xFF484848),
              thickness: 1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
      // Call API when dates are selected
      await _fetchReportData();
    }
  }

  Future<void> _fetchReportData() async {
    if (fromDate == null || toDate == null) return;

    setState(() {
      isLoading = true;
    });
    try {
      List<Datum> data = await _authenticationController.getProfileData(
        fromDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(fromDate!),
        toDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(toDate!),
        status: selectedTab == "Ongoing"
            ? 'ongoing'
            : selectedTab == "Incomplete"
                ? 'available'
                : selectedTab == "Completed"
                    ? 'completed'
                    : 'account_activity',
        page: currentPage,
        userId: '${_authenticationController.currentUser.value.id}',
      );

      setState(() {
        totalPages = (data.length / 10).ceil();
        final int startIndex = (currentPage - 1) * 10;
        campaignData = data.asMap().entries.map((entry) {
          final index = entry.key;
          final datum = entry.value;

          return {
            'id': startIndex + index + 1,
            'name': datum.name ?? 'Unknown',
            'activity': '${datum.screenshotCount}/5',
            'status': selectedTab.toLowerCase(),
          };
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching report data: $e');
    }
  }

  Future<void> _changeTab(String tab) async {
    setState(() {
      selectedTab = tab;
      currentPage = 1;
    });
    await _fetchReportData();
  }

  Future<void> _changePage(int newPage) async {
    if (newPage < 1 || newPage > totalPages) return;

    setState(() {
      currentPage = newPage;
    });
    await _fetchReportData();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }

  String _getDateRangeDisplay() {
    if (fromDate != null && toDate != null) {
      return '${_formatDate(fromDate)} - ${_formatDate(toDate)}';
    }
    return '13/6/25 - 14/6/25';
  }

  Widget _buildDatePicker(String label, bool isFromDate) {
    return GestureDetector(
      onTap: () => _selectDate(context, isFromDate),
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => _changeTab(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: isSelected
              ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
              : null,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignRow(Map<String, dynamic> campaign) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '${campaign['id']}. ${campaign['name']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              campaign['activity'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    final user = _authenticationController.currentUser.value;
    final displayName = (user.fullname?.isNotEmpty == true)
        ? user.fullname
        : user.username ?? 'User';
    final email = user.email ?? 'No email provided';
    final phone = user.phone ?? 'No phone provided';
    final from = user.createdAt;

    String calculateTimeDifferenceLong(DateTime from) {
      final DateTime now = DateTime.now();
      final int totalDays = now.difference(from).inDays;

      if (totalDays == 0) return 'Today';
      if (totalDays == 1) return '1 day';

      // For very long periods, use your original logic
      if (totalDays > 365) {
        final int years = totalDays ~/ 365;
        final int remainingDaysAfterYears = totalDays % 365;
        final int months = remainingDaysAfterYears ~/ 30;
        final int remainingDaysAfterMonths = remainingDaysAfterYears % 30;
        final int weeks = remainingDaysAfterMonths ~/ 7;
        final int days = remainingDaysAfterMonths % 7;

        List<String> parts = [];

        if (years > 0) parts.add('$years ${years == 1 ? 'year' : 'years'}');
        if (months > 0) {
          parts.add('$months ${months == 1 ? 'month' : 'months'}');
        }
        if (weeks > 0) parts.add('$weeks ${weeks == 1 ? 'week' : 'weeks'}');
        if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');

        return parts.join(', ');
      }

      // For periods less than a year, show days, hours, minutes
      final Duration difference = now.difference(from);
      final int totalMinutes = difference.inMinutes;
      final int days = totalMinutes ~/ (24 * 60);
      final int hours = (totalMinutes % (24 * 60)) ~/ 60;
      final int minutes = totalMinutes % 60;

      List<String> parts = [];

      if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');
      if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
      if (minutes > 0) {
        parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
      }

      return parts.join(' ');
    }

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: const ClipOval(
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.black,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.easeOut),

        const SizedBox(height: 20),

        // Name
        Text(
          displayName!,
          style: const TextStyle(
            fontFamily: 'Leotaro',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

        const SizedBox(height: 8),

        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'APPROVED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

        const SizedBox(height: 16),

        // Email
        Text(
          email,
          style: const TextStyle(
            fontFamily: 'TT Hoves Pro Trial',
            color: Colors.white,
            fontSize: 16,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

        const SizedBox(height: 8),

        // Phone
        Text(
          phone,
          style: const TextStyle(
            fontFamily: 'TT Hoves Pro Trial',
            color: Colors.white,
            fontSize: 16,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  calculateTimeDifferenceLong(from!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
        ),
        const SizedBox(height: 40),

        // Earnings Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.savings,
                color: Colors.white,
                size: 45,
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'You have earned a total of',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'KSH 13,450',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'so far.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 550.ms),
        const SizedBox(height: 30),

        // My Report Button
        SizedBox(
          width: 150,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                showReport = true;
              });
              _fetchReportData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'MY REPORT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

        const SizedBox(height: 20),

        // Divider
        Container(
          height: 2,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 20),
        ).animate().fadeIn(duration: 400.ms, delay: 650.ms),

        const SizedBox(height: 20),

        // Update Password Section
        const Text(
          'Update Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

        const SizedBox(height: 20),

        // Current Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your current password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const TextField(
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 750.ms),

        const SizedBox(height: 20),

        // New Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your new password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

        const SizedBox(height: 20),

        // Repeat Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repeat your new password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 850.ms),

        const SizedBox(height: 30),

        _authenticationController.isLoggingIn.value
            ? const CircularProgressIndicator(
                color: Colors.white,
              ).animate().fadeIn(duration: 400.ms, delay: 900.ms)
            : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final user = _authenticationController.currentUser.value;
                    final email = user.email;
                    final phone = user.phone;
                    final nationalId = user.nationalId;
                    _authenticationController.resetPassword(
                        isLoggedIn: true,
                        username: user.username!,
                        email: email!,
                        phone: phone!,
                        nationalId: nationalId.toString(),
                        password: passwordController.text,
                        passwordConfirmation: confirmPasswordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'UPDATE PASSWORD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 900.ms),
      ],
    );
  }

  Widget _buildReportView() {
    final user = _authenticationController.currentUser.value;
    final displayName = (user.fullname?.isNotEmpty == true)
        ? user.fullname
        : user.username ?? 'User';
    final email = user.email ?? 'No email provided';
    final phone = user.phone ?? 'No phone provided';
    final from = user.createdAt;

    String calculateTimeDifferenceLong(DateTime from) {
      final DateTime now = DateTime.now();
      final int totalDays = now.difference(from).inDays;

      if (totalDays == 0) return 'Today';
      if (totalDays == 1) return '1 day';

      // For very long periods, use your original logic
      if (totalDays > 365) {
        final int years = totalDays ~/ 365;
        final int remainingDaysAfterYears = totalDays % 365;
        final int months = remainingDaysAfterYears ~/ 30;
        final int remainingDaysAfterMonths = remainingDaysAfterYears % 30;
        final int weeks = remainingDaysAfterMonths ~/ 7;
        final int days = remainingDaysAfterMonths % 7;

        List<String> parts = [];

        if (years > 0) parts.add('$years ${years == 1 ? 'year' : 'years'}');
        if (months > 0) {
          parts.add('$months ${months == 1 ? 'month' : 'months'}');
        }
        if (weeks > 0) parts.add('$weeks ${weeks == 1 ? 'week' : 'weeks'}');
        if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');

        return parts.join(', ');
      }

      // For periods less than a year, show days, hours, minutes
      final Duration difference = now.difference(from);
      final int totalMinutes = difference.inMinutes;
      final int days = totalMinutes ~/ (24 * 60);
      final int hours = (totalMinutes % (24 * 60)) ~/ 60;
      final int minutes = totalMinutes % 60;

      List<String> parts = [];

      if (days > 0) parts.add('$days ${days == 1 ? 'day' : 'days'}');
      if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
      if (minutes > 0) {
        parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
      }

      return parts.join(' ');
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: const ClipOval(
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 20),
        Text(
          displayName!,
          style: const TextStyle(
            fontFamily: 'Leotaro',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'APPROVED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),
        Text(
          email,
          style: const TextStyle(
            fontFamily: 'TT Hoves Pro Trial',
            color: Colors.white,
            fontSize: 16,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

        const SizedBox(height: 8),
        Text(
          phone,
          style: const TextStyle(
            fontFamily: 'TT Hoves Pro Trial',
            color: Colors.white,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  calculateTimeDifferenceLong(from!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Earnings Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.savings,
                color: Colors.white,
                size: 45,
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'You have earned a total of',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'KSH 13,450',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'so far.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),

        // My Performance Report Section
        const Text(
          'My Performance Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 65),
          child: Divider(
            color: Colors.white,
            thickness: 2,
            height: 20,
          ),
        ),

        const SizedBox(height: 12),

        // Date Selection Instruction
        const Text(
          'Select the dates in which you want to see reports from below.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Date Pickers Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDatePicker('FROM', true),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 119, 71, 7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: const Text(
                    'SHOWING FOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDateRangeDisplay(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '12:00 AM - 12:00 AM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            _buildDatePicker('TO', false),
          ],
        ),

        const SizedBox(height: 16),

        // Tabs Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabButton('Ongoing', selectedTab == 'Ongoing'),
            _buildTabButton('Incomplete', selectedTab == 'Incomplete'),
            _buildTabButton('Completed', selectedTab == 'Completed'),
          ],
        ),

        const SizedBox(height: 16),

        // Campaign List Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            children: [
              // Header Row
              const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Campaign',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Campaign Rows
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: campaignData.length,
                  itemBuilder: (context, index) =>
                      _buildCampaignRow(campaignData[index]),
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 2,
                      height: 2,
                    ),
                  ),
                )
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pagination Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap:
                  currentPage > 1 ? () => _changePage(currentPage - 1) : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: currentPage > 1 ? Colors.white : Colors.grey[600],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PREVIOUS',
                  style: TextStyle(
                    color: currentPage > 1 ? Colors.black : Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text(
              'PAGE $currentPage OF $totalPages',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: currentPage < totalPages
                  ? () => _changePage(currentPage + 1)
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: currentPage < totalPages
                      ? Colors.white
                      : Colors.grey[600],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NEXT',
                  style: TextStyle(
                    color: currentPage < totalPages
                        ? Colors.black
                        : Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Download Full PDF Report Button
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              // Handle PDF download
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'DOWNLOAD FULL PDF REPORT',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.black,
          shadowColor: Colors.black,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                _authenticationController.logOut();
              },
            ),
          ],
        ),
        body: Obx(
          () => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (showReport)
                    GestureDetector(
                      onTap: () => setState(() => showReport = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'BACK TO PROFILE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  showReport ? _buildReportView() : _buildProfileView(),

                  const SizedBox(height: 30),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ALL RIGHTS RESERVED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Center(
                          child: Text(
                            'Visible.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
