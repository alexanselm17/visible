import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/model/users/user_dashboard.dart';
import 'package:visible/screens/profile_page.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    authenticationController.loadUserData();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      debugPrint('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                onTap: () => Get.to(const ProfilePage()),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        authenticationController
                                    .currentUser.value.username?.isNotEmpty ==
                                true
                            ? authenticationController
                                .currentUser.value.username!
                            : 'Jefferson\nInyanje',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
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
              const SizedBox(width: 12),
              GestureDetector(
                  onTap: _loadDashboardData,
                  child:
                      const Icon(Icons.refresh, color: Colors.black, size: 24)),
              const SizedBox(width: 8),
              const Icon(Icons.notifications_outlined,
                  color: Colors.black, size: 24),
            ],
          ),
        ),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Earnings Summary Card
                  _buildEarningsSummaryCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Progress Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressTracker(),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 45),
                    child: Divider(
                      color: Colors.white,
                      thickness: 3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActiveCampaigns(),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 45),
                    child: Divider(
                      color: Colors.white,
                      thickness: 3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Recent Earnings
                  _buildRecentEarnings(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildEarningsSummaryCard() {
    final data = _dashboardData?.data;
    bool hasData = data != null &&
        (data.totalRewards != null && data.totalRewards! > 0 ||
            data.todayRewards?.amount != null &&
                data.todayRewards!.amount! > 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: hasData
          ? _buildEarningsWithData(data)
          : _buildEarningsWithAchievements(),
    );
  }

  Widget _buildEarningsWithData(UserDashboardModelData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Earnings
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ksh ${data.pendingBalance ?? 50}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 1,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 24),
              const Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ksh ${data.todayRewards?.amount ?? 25}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right side - Achievements
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAchievementItem(
                icon: Icons.emoji_events,
                color: Colors.amber,
                title: 'Completion Master',
                subtitle:
                    'You have just completed\nyour first Ad Campaign. The engine is now hot.\n#LetsGetGo30',
              ),
              const SizedBox(height: 16),
              _buildAchievementItem(
                icon: Icons.emoji_events,
                color: Colors.amber,
                title: 'Here\'s a trophy',
                subtitle:
                    'Thanks for Signing up to Visible.\nWe have more trophies like these for you in store.\nYou are awesome.',
              ),
              const SizedBox(height: 16),
              _buildAchievementItem(
                icon: Icons.account_balance_wallet,
                color: Colors.pink,
                title: 'Money in the bank',
                subtitle:
                    'At this rate, you will need a bodyguard.\nYou have just made your first cash by posting\nan AD Campaign. Go post some more!',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsWithAchievements() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Earnings (No data)
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pending',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ksh 0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 1,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 24),
              const Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ksh 0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right side - No Achievements
        const Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Achievements',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'No Achievements yet.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Start your journey with us and your achievements\nwill be displayed here.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTracker() {
    final achievements = _dashboardData?.data?.achievements;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildProgressCircle(
          'Daily',
          achievements?.daily?.completed ?? 0,
          achievements?.daily?.created ?? 0,
        ),
        _buildProgressCircle(
          'Weekly',
          achievements?.weekly?.completed ?? 0,
          achievements?.weekly?.created ?? 0,
        ),
        _buildProgressCircle(
          'Monthly',
          achievements?.monthly?.completed ?? 0,
          achievements?.monthly?.created ?? 0,
        ),
      ],
    );
  }

  Widget _buildProgressCircle(String label, int completed, int total) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
            child: Text(
              '$completed/$total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCampaigns() {
    final campaignsData = _dashboardData?.data?.ongoing?.data?.data;
    bool hasCampaigns = campaignsData != null && campaignsData.isNotEmpty;

    if (!hasCampaigns) {
      return _buildNoCampaigns();
    }

    return Column(
      children: [
        // Campaign card with sliding functionality
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: campaignsData.length,
            itemBuilder: (context, index) {
              final campaign = campaignsData[index];
              return _buildCampaignCard(campaign);
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            campaignsData.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignCard(Datum campaign) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        children: [
          // Campaign image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(campaign.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage(
                          'assets/johnnie_walker.png'), // You'll need to add this asset
                      fit: BoxFit.cover,
                    ),
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Campaign details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.name ?? 'JOHNNY WALKER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Ksh 50',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeRemaining(campaign.validUntil),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  // Progress circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        '2/5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'VERIFICATION PENDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoCampaigns() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.campaign_outlined,
            size: 60,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Campaigns.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Active and Ongoing Campaigns\nWill appear here. Select an Ad Campaign\nfrom the Ad campaigns tab to get going.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEarnings() {
    final recentRewards = _dashboardData?.data?.recentRewards;
    bool hasEarnings = recentRewards != null && recentRewards.isNotEmpty;

    if (!hasEarnings) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'No Recent Earnings.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Earnings from successfully completed\nAd Campaigns will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return Column(
      children: recentRewards.map((earning) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Text(
                  earning.advertName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'KSH ${earning.amount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'EARNED',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getTimeRemaining(DateTime? validUntil) {
    if (validUntil == null) return 'Expires in 4h 8m';

    final now = DateTime.now();
    final difference = validUntil.difference(now);

    if (difference.isNegative) return 'Expired';

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return 'Expires in ${days}d ${hours}h';
    } else if (hours > 0) {
      return 'Expires in ${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return 'Expires in ${minutes}m';
    } else {
      return 'Expiring soon';
    }
  }
}
