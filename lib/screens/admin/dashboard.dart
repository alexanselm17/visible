import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/model/users/admin_dashboard.dart';
import 'package:visible/screens/admin/users/user_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  static const routeName = '/admin/dashboard';

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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

  // Data from API
  Data? _dashboardData;

  void _showPopupMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(
          value: '1',
          child: Row(
            children: [
              Text('Profile'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: '3',
          child: Row(
            children: [
              Text('Employees'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: '4',
          child: Row(
            children: [
              Text('Download Payroll'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: '2',
          child: Row(
            children: [
              Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
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
      case '2':
        Get.put<AuthenticationController>(AuthenticationController()).logOut();
        break;
      case '3':
        Get.to(const UsersScreen());
      case '4':
        Get.put<AuthenticationController>(AuthenticationController())
            .downloadPayRoll();

        break;

      case 'delete':
        print('Delete selected');
        break;
    }
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
          'Failed to load dashboard data',
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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 180,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showPopupMenu(context);
                },
                child: const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(
                    'assets/images/8ebb1801-6af2-4a3b-b0c4-ae4a7de2b09d_removalai_preview.png',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  authenticationController.currentUser.value.username ??
                      'Admin',
                  style: const TextStyle(
                    fontFamily: 'TT Hoves Pro Trial',
                    color: AppColors.primaryBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.primaryBlack),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlack),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange))
          : _dashboardData == null
              ? const Center(
                  child: Text('No data available'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time filter
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dashboard Overview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedTimeFilter,
                              underline: Container(),
                              icon: const Icon(Icons.keyboard_arrow_down),
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

                      // Stat cards row 1
                      Row(
                        children: [
                          _buildStatCard(
                            'Total Users',
                            (_dashboardData!.totalUsers ?? 0).toString(),
                            Icons.people,
                            Colors.blue,
                            'Registered users',
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'Ongoing Campaigns',
                            (_dashboardData!.ongoing ?? 0).toString(),
                            Icons.campaign,
                            Colors.green,
                            'Out of ${_dashboardData!.campaignsCreated ?? 0}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stat cards row 2
                      Row(
                        children: [
                          _buildStatCard(
                            'Completed',
                            (_dashboardData!.completed ?? 0).toString(),
                            Icons.done_all,
                            Colors.purple,
                            'Campaigns completed',
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'Rewards Assigned',
                            (_dashboardData!.rewardsAssigned ?? 0).toString(),
                            Icons.card_giftcard,
                            Colors.orange,
                            'Total rewards',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stat cards row 3
                      Row(
                        children: [
                          _buildStatCard(
                            'Payment Done',
                            'Ksh ${NumberFormat('#,###').format(_dashboardData!.paymentDone ?? 0)}',
                            Icons.payment,
                            Colors.green,
                            'Payments completed',
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'Pending Payment',
                            'Ksh ${NumberFormat('#,###').format(_dashboardData!.pendingPayment ?? 0)}',
                            Icons.pending,
                            Colors.red,
                            'Awaiting payment',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Unused Slots Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.inventory,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Unused Campaign Slots',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (_dashboardData!.unusedSlots ?? 0).toString(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Available slots for new campaigns',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Top Campaigns
                      if (_dashboardData!.topCampaigns != null &&
                          _dashboardData!.topCampaigns!.isNotEmpty) ...[
                        _buildSectionTitle(
                            'Top Campaigns', 'Highest completion rates'),
                        const SizedBox(height: 8),
                        _buildTopCampaignsList(),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
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
                        fontWeight: FontWeight.bold,
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
