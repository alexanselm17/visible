import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/model/users/user_dashboard.dart';
import 'package:visible/widgets/loading_indicator.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});
  static const routeName = '/user/dashboard';
  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());
  bool _isLoading = true;
  UserDashboardModel? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await authenticationController.getUserDashboard();
      if (data != null) {
        setState(() {
          _dashboardData = UserDashboardModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                  'assets/images/8ebb1801-6af2-4a3b-b0c4-ae4a7de2b09d_removalai_preview.png',
                ),
              ),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  authenticationController.currentUser.value.username ?? 'User',
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
              child: AnimatedLoadingIndicator(
                isLoading: true,
                primaryColor: AppColors.accentOrange,
                secondaryColor: Colors.white,
                size: 50,
                loadingText: 'Loading dashboard...',
              ),
            )
          : _dashboardData?.data == null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile and earnings summary
                      _buildEarningsSummary(),
                      const SizedBox(height: 24),

                      // Daily Goals
                      _buildSectionTitle('Your Goals', 'Progress tracker'),
                      const SizedBox(height: 8),
                      _buildGoalsProgress(),
                      const SizedBox(height: 24),

                      // Recent Rewards
                      if (_dashboardData!.data!.recentRewards?.isNotEmpty ??
                          false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                                'Recent Rewards', 'Your earnings'),
                            const SizedBox(height: 8),
                            _buildRecentRewards(),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Ongoing Campaigns Section
                      _buildSectionTitle(
                          'Campaign Status', 'Current activities'),
                      const SizedBox(height: 8),
                      _buildOngoingSection(),
                      const SizedBox(height: 24),

                      // Refer a Friend Card
                      _buildReferralCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load dashboard data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSummary() {
    final data = _dashboardData!.data!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentOrange, Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ksh ${data.totalRewards ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEarningsDetail(
                  'Today', 'Ksh ${data.todayRewards?.amount ?? 0}'),
              _buildEarningsDetail('Pending', data.pendingBalance ?? 'Ksh 0'),
              _buildEarningsDetail('Campaigns', '${data.totalCampaigns ?? 0}'),
              _buildEarningsDetail(
                  'Today Tasks', '${data.todayRewards?.count ?? 0}'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildEarningsDetail(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
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

  Widget _buildGoalsProgress() {
    final achievements = _dashboardData!.data!.achievements;
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGoalProgressIndicator(
            'Daily',
            achievements?.daily?.completed ?? 0,
            achievements?.daily?.created ?? 1,
            Colors.blue,
          ),
          _buildGoalProgressIndicator(
            'Weekly',
            achievements?.weekly?.completed ?? 0,
            achievements?.weekly?.created ?? 1,
            Colors.purple,
          ),
          _buildGoalProgressIndicator(
            'Monthly',
            achievements?.monthly?.completed ?? 0,
            achievements?.monthly?.created ?? 1,
            AppColors.accentOrange,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildGoalProgressIndicator(
      String title, int completed, int target, Color color) {
    double percent = target > 0 ? completed / target : 0;
    if (percent > 1) percent = 1.0;

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 35.0,
          lineWidth: 8.0,
          percent: percent,
          center: Text(
            '$completed/$target',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          progressColor: color,
          backgroundColor: Colors.grey.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1000,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRewards() {
    final recentRewards = _dashboardData!.data!.recentRewards ?? [];

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
        children: recentRewards.take(5).map<Widget>((reward) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.advertName ?? 'Campaign Reward',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward.createdAt != null
                              ? DateFormat('dd MMM yyyy')
                                  .format(reward.createdAt!)
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ksh ${reward.amount ?? '0'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.type?.toUpperCase() ?? 'CREDITED',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildOngoingSection() {
    final ongoing = _dashboardData!.data!.ongoing;

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
        children: [
          Row(
            children: [
              const Icon(
                Icons.campaign,
                color: AppColors.accentOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ongoing?.message ?? 'Campaign Status',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total ongoing: ${ongoing?.pagination?.total ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${ongoing?.pagination?.total ?? 0}',
                  style: const TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (ongoing?.pagination?.total == 0) ...[
            const SizedBox(height: 16),
            Text(
              'No ongoing campaigns at the moment',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildReferralCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.people,
              color: Colors.indigo,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Refer a Friend',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Earn Ksh 100 for each friend who joins and completes their first campaign',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Show referral options
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo,
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0);
  }
}
