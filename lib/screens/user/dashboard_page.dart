import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visible/constants/colors.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});
  static const routeName = '/user/dashboard';
  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  bool _isLoading = false;

  // Mock data for user dashboard
  final Map<String, dynamic> _userStats = {
    'name': 'Rahul Mehta',
    'level': 'Gold',
    'totalEarnings': 'Ksh  3,250',
    'pendingEarnings': 'Ksh  250',
    'earnedToday': 'Ksh  75',
    'statusShared': 48,
    'pendingVerifications': 2,
    'completedCampaigns': 23,
    'streak': 5,
    'rewardsHistory': [
      {
        'date': '2025-04-19',
        'campaign': 'Summer Sale',
        'reward': 'Ksh 75',
        'status': 'Credited',
      },
      {
        'date': '2025-04-18',
        'campaign': 'New Launch',
        'reward': 'Ksh 50',
        'status': 'Credited',
      },
      {
        'date': '2025-04-17',
        'campaign': 'Weekend Special',
        'reward': 'Ksh 100',
        'status': 'Credited',
      },
      {
        'date': '2025-04-16',
        'campaign': 'Flash Discount',
        'reward': 'Ksh 75',
        'status': 'Credited',
      },
      {
        'date': '2025-04-15',
        'campaign': 'Summer Sale',
        'reward': 'Ksh 75',
        'status': 'Credited',
      },
    ],
    'pendingVerifications': [
      {
        'id': 123,
        'campaign': 'Summer Offer',
        'submittedAt': '10:23 AM',
        'reward': 'Ksh 75',
        'image':
            'assets/images/coco-noir-chanel-pink-aesthetic-plrz6za4j9w81o44.png',
      },
      {
        'id': 124,
        'campaign': 'Flash Sale',
        'submittedAt': 'Yesterday, 4:30 PM',
        'reward': 'Ksh 50',
        'image': 'assets/images/668adc4fcd57736f5c718ef6_product-12.png',
      },
    ],
    'availableCampaigns': [
      {
        'id': 1,
        'name': 'Summer Sale',
        'reward': 'Ksh 75 Cashback',
        'duration': '2 days left',
        'image': 'assets/images/Glowify-gallery-img-1.png',
        'completed': false,
      },
      {
        'id': 2,
        'name': 'New Launch',
        'reward': 'Ksh 100 Discount',
        'duration': '5 days left',
        'image': 'assets/images/668adc4fcd57736f5c718ef9_product-18.png',
        'completed': false,
      },
      {
        'id': 3,
        'name': 'Weekend Special',
        'reward': 'Ksh 50 Cashback',
        'duration': '1 day left',
        'image': 'assets/images/668adc4fcd57736f5c718ef0_product-06.png',
        'completed': true,
      },
    ],
    'goals': {
      'daily': {
        'target': 2,
        'completed': 1,
      },
      'weekly': {
        'target': 10,
        'completed': 5,
      },
      'monthly': {
        'target': 40,
        'completed': 23,
      }
    },
    'achievements': [
      {
        'name': 'First Share',
        'description': 'Share your first status',
        'completed': true,
        'icon': Icons.share,
      },
      {
        'name': 'Streak Master',
        'description': 'Complete 5-day streak',
        'completed': true,
        'icon': Icons.local_fire_department,
      },
      {
        'name': 'Campaign Pro',
        'description': 'Complete 20 campaigns',
        'completed': true,
        'icon': Icons.campaign,
      },
      {
        'name': 'Earning Milestone',
        'description': 'Earn total of Ksh 3,000',
        'completed': true,
        'icon': Icons.stars,
      },
      {
        'name': 'Social Butterfly',
        'description': 'Share 50 statuses',
        'completed': false,
        'progress': 0.96, // 48/50
        'icon': Icons.publish,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 180, // enough space for avatar + name
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                  'assets/images/8ebb1801-6af2-4a3b-b0c4-ae4a7de2b09d_removalai_preview.png',
                ),
              ),
              SizedBox(width: 8),
              Text(
                'John Doe',
                style: TextStyle(
                  fontFamily: 'TT Hoves Pro Trial',
                  color: AppColors.primaryBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
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
                  // User profile and earnings summary
                  _buildEarningsSummary(),
                  const SizedBox(height: 24),

                  // Daily Goals
                  _buildSectionTitle('Your Goals', 'Progress tracker'),
                  const SizedBox(height: 8),
                  _buildGoalsProgress(),
                  const SizedBox(height: 24),

                  // Available Campaigns
                  _buildSectionTitle('Available Campaigns', 'Earn rewards'),
                  const SizedBox(height: 8),
                  _buildAvailableCampaigns(),
                  const SizedBox(height: 24),

                  // Pending Verifications
                  if (_userStats['pendingVerifications'].length > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                            'Pending Verifications', 'Waiting for approval'),
                        const SizedBox(height: 8),
                        _buildPendingVerifications(),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Recent Rewards
                  _buildSectionTitle('Recent Rewards', 'Your earnings'),
                  const SizedBox(height: 8),
                  _buildRecentRewards(),
                  const SizedBox(height: 24),

                  // Achievements
                  _buildSectionTitle('Achievements', 'Your milestones'),
                  const SizedBox(height: 8),
                  _buildAchievements(),
                  const SizedBox(height: 24),

                  // Refer a Friend Card
                  _buildReferralCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildEarningsSummary() {
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
                    _userStats['totalEarnings'],
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
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_userStats['streak']} Day Streak',
                      style: const TextStyle(
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
              _buildEarningsDetail('Today', _userStats['earnedToday']),
              _buildEarningsDetail('Pending', _userStats['pendingEarnings']),
              _buildEarningsDetail(
                  'Campaigns', _userStats['completedCampaigns'].toString()),
              _buildEarningsDetail(
                  'Shared', _userStats['statusShared'].toString()),
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
            _userStats['goals']['daily']['completed'],
            _userStats['goals']['daily']['target'],
            Colors.blue,
          ),
          _buildGoalProgressIndicator(
            'Weekly',
            _userStats['goals']['weekly']['completed'],
            _userStats['goals']['weekly']['target'],
            Colors.purple,
          ),
          _buildGoalProgressIndicator(
            'Monthly',
            _userStats['goals']['monthly']['completed'],
            _userStats['goals']['monthly']['target'],
            AppColors.accentOrange,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildGoalProgressIndicator(
      String title, int completed, int target, Color color) {
    double percent = completed / target;
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

  Widget _buildAvailableCampaigns() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _userStats['availableCampaigns'].length,
        itemBuilder: (context, index) {
          final campaign = _userStats['availableCampaigns'][index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
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
                // Campaign image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        campaign['image'],
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (campaign['completed'])
                        Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.6),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign['reward'],
                        style: const TextStyle(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign['duration'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (100 * index).ms)
              .slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildPendingVerifications() {
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
        children:
            _userStats['pendingVerifications'].map<Widget>((verification) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    verification['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verification['campaign'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitted at ${verification['submittedAt']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pending reward: ${verification['reward']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.hourglass_top,
                  color: Colors.orange,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildRecentRewards() {
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
        children: _userStats['rewardsHistory'].take(3).map<Widget>((reward) {
          final date = DateTime.parse(reward['date']);
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
                          reward['campaign'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(date),
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
                      reward['reward'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward['status'],
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

  Widget _buildAchievements() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _userStats['achievements'].length,
        itemBuilder: (context, index) {
          final achievement = _userStats['achievements'][index];
          final bool completed = achievement['completed'] ?? false;
          final double progress = achievement['progress'] ?? 0.0;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularPercentIndicator(
                      radius: 25.0,
                      lineWidth: 4.0,
                      percent: completed ? 1.0 : progress,
                      progressColor:
                          completed ? Colors.green : AppColors.accentOrange,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      center: Icon(
                        achievement['icon'],
                        color:
                            completed ? Colors.green : AppColors.accentOrange,
                        size: 22,
                      ),
                    ),
                    if (completed)
                      const Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  achievement['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  completed ? 'Completed' : 'In progress',
                  style: TextStyle(
                    fontSize: 10,
                    color: completed ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: (100 * index).ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
        },
      ),
    );
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
