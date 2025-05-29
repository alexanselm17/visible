import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
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
    'All Time'
  ];
  String _selectedTimeFilter = 'This Week';
  bool _isLoading = false;

  // Mock data for dashboard statistics
  final Map<String, dynamic> _dashboardStats = {
    'totalUsers': 15782,
    'activeUsers': 8453,
    'totalCampaigns': 48,
    'activeCampaigns': 12,
    'totalImagesDownloaded': 27896,
    'totalStatusShared': 18453,
    'pendingVerifications': 345,
    'rewardsIssued': {
      'total': 'Ksh 238,450',
      'today': 'Ksh 12,350',
    },
    'userGrowth': [
      {'date': '2025-04-13', 'count': 210},
      {'date': '2025-04-14', 'count': 245},
      {'date': '2025-04-15', 'count': 278},
      {'date': '2025-04-16', 'count': 312},
      {'date': '2025-04-17', 'count': 370},
      {'date': '2025-04-18', 'count': 410},
      {'date': '2025-04-19', 'count': 465},
    ],
    'campaignPerformance': [
      {
        'name': 'Summer Sale',
        'downloads': 1235,
        'shares': 982,
        'verifications': 876,
        'conversionRate': 70.9,
      },
      {
        'name': 'New Launch',
        'downloads': 875,
        'shares': 632,
        'verifications': 581,
        'conversionRate': 66.4,
      },
      {
        'name': 'Flash Discount',
        'downloads': 1587,
        'shares': 1352,
        'verifications': 1203,
        'conversionRate': 75.8,
      },
      {
        'name': 'Weekend Special',
        'downloads': 743,
        'shares': 621,
        'verifications': 584,
        'conversionRate': 78.6,
      },
    ],
    'recentActivities': [
      {
        'user': 'Priya Sharma',
        'action': 'Shared status',
        'campaign': 'Summer Sale',
        'time': '2 minutes ago',
        'status': 'Pending Verification',
        'image': 'assets/images/avatar1.png',
      },
      {
        'user': 'Rahul Mehta',
        'action': 'Verified Status',
        'campaign': 'New Launch',
        'time': '15 minutes ago',
        'status': 'Reward Issued: Ksh 75',
        'image': 'assets/images/avatar2.png',
      },
      {
        'user': 'Neha Gupta',
        'action': 'Downloaded Image',
        'campaign': 'Flash Discount',
        'time': '32 minutes ago',
        'status': 'Pending Share',
        'image': 'assets/images/avatar3.png',
      },
      {
        'user': 'Vikram Singh',
        'action': 'Registered',
        'campaign': '-',
        'time': '1 hour ago',
        'status': 'New User',
        'image': 'assets/images/avatar4.png',
      },
    ],
  };

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
        break;
      // case '1':
      //   Get.to(const ProfileScreen());
      case 'delete':
        print('Delete selected');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    authenticationController.getAdminDashboard(query: 'this_month');
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
                  authenticationController.currentUser.value.username!,
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
            onPressed: () {
              setState(() {
                _isLoading = true;
              });

              // Simulate loading delay
              Future.delayed(const Duration(milliseconds: 800), () {
                setState(() {
                  _isLoading = false;
                });
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time filter
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        _dashboardStats['totalUsers'].toString(),
                        Icons.people,
                        Colors.blue,
                        '+12% this week',
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Active Campaigns',
                        _dashboardStats['activeCampaigns'].toString(),
                        Icons.campaign,
                        Colors.green,
                        'Out of ${_dashboardStats['totalCampaigns']}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stat cards row 2
                  Row(
                    children: [
                      _buildStatCard(
                        'Status Shares',
                        _dashboardStats['totalStatusShared'].toString(),
                        Icons.share,
                        Colors.purple,
                        '${(_dashboardStats['totalStatusShared'] / _dashboardStats['totalImagesDownloaded'] * 100).toStringAsFixed(1)}% conversion',
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Rewards Issued',
                        _dashboardStats['rewardsIssued']['total'],
                        Icons.card_giftcard,
                        Colors.orange,
                        '${_dashboardStats['rewardsIssued']['today']} today',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Growth Chart
                  _buildSectionTitle('User Growth', 'Last 7 days'),
                  const SizedBox(height: 8),
                  Container(
                    height: 220,
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
                    child: _buildUserGrowthChart(),
                  ),
                  const SizedBox(height: 24),

                  // Campaign Performance
                  _buildSectionTitle(
                      'Campaign Performance', 'Top performing campaigns'),
                  const SizedBox(height: 8),
                  _buildCampaignPerformanceList(),
                  const SizedBox(height: 24),

                  // Recent Activities
                  _buildSectionTitle('Recent Activities', 'Live updates'),
                  const SizedBox(height: 8),
                  _buildRecentActivitiesList(),
                  const SizedBox(height: 24),
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

  Widget _buildUserGrowthChart() {
    final List<FlSpot> spots = [];

    for (int i = 0; i < _dashboardStats['userGrowth'].length; i++) {
      spots.add(FlSpot(
          i.toDouble(), _dashboardStats['userGrowth'][i]['count'].toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < _dashboardStats['userGrowth'].length) {
                  final date = DateTime.parse(
                      _dashboardStats['userGrowth'][value.toInt()]['date']);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_dashboardStats['userGrowth'].length - 1).toDouble(),
        minY: 0,
        maxY: 500,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [
                AppColors.accentOrange,
                Color(0xFFFF9800),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.accentOrange,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.accentOrange.withOpacity(0.3),
                  AppColors.accentOrange.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignPerformanceList() {
    return Column(
      children: _dashboardStats['campaignPerformance'].map<Widget>((campaign) {
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
                  Text(
                    campaign['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                      '${campaign['conversionRate']}% Conversion',
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
                  _buildCampaignStat('Downloads', campaign['downloads']),
                  _buildCampaignStat('Shares', campaign['shares']),
                  _buildCampaignStat('Verified', campaign['verifications']),
                ],
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
          value.toString(),
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

  Widget _buildRecentActivitiesList() {
    return Container(
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
        children: _dashboardStats['recentActivities'].map<Widget>((activity) {
          Color statusColor;
          if (activity['status'].toString().contains('Pending')) {
            statusColor = Colors.orange;
          } else if (activity['status'].toString().contains('Reward')) {
            statusColor = Colors.green;
          } else if (activity['status'].toString().contains('New')) {
            statusColor = Colors.blue;
          } else {
            statusColor = Colors.grey;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(activity['image']),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            activity['user'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            activity['time'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activity['action']} - ${activity['campaign']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity['status'],
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
