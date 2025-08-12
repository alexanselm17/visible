import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/model/users/admin_dashboard.dart';
import 'package:visible/screens/admin/upload-payment_excel.dart';
import 'package:visible/screens/admin/users/user_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  static const routeName = '/admin/dashboard';

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const Color accentOrange = Color(0xFFFF7F00);

  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  final List<String> _timeFilters = [
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];
  String _selectedTimeFilter = 'This Week';
  bool _isLoading = false;
  Data? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      String query = _getQueryFromTimeFilter(_selectedTimeFilter);
      var res = await authenticationController.getAdminDashboard(query: query);
      setState(() {
        _dashboardData = AdminModel.fromJson(res).data;
      });
      if (!mounted) return;
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to load dashboard data: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getQueryFromTimeFilter(String timeFilter) {
    switch (timeFilter) {
      case 'Today':
        return 'today';
      case 'This Week':
        return 'this_week';
      case 'This Month':
        return 'this_month';
      case 'This Year':
        return 'this_year';
      default:
        return 'this_week';
    }
  }

  void _showProfileMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        0, // Left
        AppBar().preferredSize.height, // Top (below app bar)
        MediaQuery.of(context).size.width, // Right
        0, // Bottom
      ),
      items: [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20, color: Colors.black87),
              const SizedBox(width: 10),
              Text('Profile', style: TextStyle(color: Colors.grey[800])),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'employees',
          child: Row(
            children: [
              const Icon(Icons.people_outline, size: 20, color: Colors.black87),
              const SizedBox(width: 10),
              Text('Employees', style: TextStyle(color: Colors.grey[800])),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'download_payroll',
          child: Row(
            children: [
              const Icon(Icons.download_outlined,
                  size: 20, color: Colors.black87),
              const SizedBox(width: 10),
              Text('Download Payroll',
                  style: TextStyle(color: Colors.grey[800])),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Upload Payment Excel',
          child: Row(
            children: [
              const Icon(Icons.upload_file_outlined,
                  size: 20, color: Colors.black87),
              const SizedBox(width: 10),
              Text('Upload Payment Excel',
                  style: TextStyle(color: Colors.grey[800])),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: Colors.red),
              SizedBox(width: 10),
              Text('Log Out', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleAction(value);
      }
    });
  }

  void _handleAction(String value) {
    switch (value) {
      case 'profile':
        // Navigate to profile page
        Get.snackbar('Info', 'Profile page coming soon!');
        break;
      case 'employees':
        Get.to(() => const UsersScreen());
        break;
      case 'download_payroll':
        authenticationController.downloadPayRoll();
        break;
      case 'Upload Payment Excel':
        Get.to(const UploadPaymentExcelPage());
        break;

      case 'logout':
        authenticationController.logOut();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 180,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showProfileMenu(context);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  child: Obx(
                    () => Text(
                      (authenticationController.currentUser.value.username ??
                              'A')[0]
                          .toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  authenticationController.currentUser.value.username ??
                      'Admin',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: null,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {
              // Show notifications
              Get.snackbar('Info', 'No new notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: accentOrange),
            )
          : _dashboardData == null
              ? const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dashboard Header with Time Filter
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dashboard Overview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedTimeFilter,
                              underline: Container(),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey),
                              items: _timeFilters.map((String filter) {
                                return DropdownMenuItem<String>(
                                  value: filter,
                                  child: Text(filter),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedTimeFilter = newValue;
                                  });
                                  _loadDashboardData();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stat cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2, // Adjust as needed
                        children: [
                          _buildStatCard(
                            'Total Users',
                            (_dashboardData!.totalUsers ?? 0).toString(),
                            Icons.people_outline,
                            Colors.blue,
                            'Registered users',
                          ),
                          _buildStatCard(
                            'Ongoing Campaigns',
                            (_dashboardData!.ongoing ?? 0).toString(),
                            Icons.campaign_outlined,
                            accentOrange,
                            'Out of ${_dashboardData!.campaignsCreated ?? 0}',
                          ),
                          _buildStatCard(
                            'Completed Campaigns',
                            (_dashboardData!.completed ?? 0).toString(),
                            Icons.done_all_outlined,
                            Colors.green,
                            'Campaigns completed',
                          ),
                          _buildStatCard(
                            'Rewards Assigned',
                            "Ksh ${NumberFormat('#,###').format(_dashboardData!.rewardsAssigned ?? 0)}",
                            Icons.card_giftcard_outlined,
                            Colors.purple,
                            'Total rewards',
                          ),
                          _buildStatCard(
                            'Payment Done',
                            'Ksh ${NumberFormat('#,###').format(_dashboardData!.paymentDone ?? 0)}',
                            Icons.payment_outlined,
                            Colors.green,
                            'Payments completed',
                          ),
                          _buildStatCard(
                            'Pending Payment',
                            'Ksh ${NumberFormat('#,###').format(_dashboardData!.pendingPayment ?? 0)}',
                            Icons.pending_actions_outlined,
                            Colors.red,
                            'Awaiting payment',
                          ),
                          _buildStatCard(
                            'Unused Slots',
                            (_dashboardData!.unusedSlots ?? 0).toString(),
                            Icons.inventory_2_outlined,
                            Colors.amber,
                            'Available slots for new campaigns',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Top Campaigns
                      if (_dashboardData!.topCampaigns != null &&
                          _dashboardData!.topCampaigns!.isNotEmpty) ...[
                        _buildSectionTitle(
                            'Top Campaigns', 'Highest completion rates'),
                        const SizedBox(height: 12),
                        _buildTopCampaignsList(),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCampaignsList() {
    return Column(
      children: _dashboardData!.topCampaigns!.map<Widget>((campaign) {
        double completionRate = 0.0;
        if (campaign.capacity != null && campaign.capacity! > 0) {
          completionRate = (campaign.completed ?? 0) / campaign.capacity! * 100;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaign.name ?? 'Unknown Campaign',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${completionRate.toStringAsFixed(1)}% Complete',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCampaignStat('Completed', campaign.completed ?? 0),
                  _buildCampaignStat('Capacity', campaign.capacity ?? 0),
                  _buildCampaignStat('Reward Total', campaign.rewardTotal ?? 0),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              LinearProgressIndicator(
                value: completionRate / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCampaignStat(String label, int value) {
    return Column(
      children: [
        Text(
          label == 'Reward Total'
              ? 'Ksh ${NumberFormat('#,###').format(value)}'
              : value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
