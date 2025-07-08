import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/campaign_controller.dart';
import 'package:visible/screens/admin/campaign/campaign_detail.dart';
import 'package:visible/screens/admin/campaign/create_campaign.dart';
import 'package:visible/screens/reports/all_campaigns_report.dart';
import 'package:visible/widgets/loading_indicator.dart';

class AdminCampaignPage extends StatefulWidget {
  const AdminCampaignPage({super.key});

  static const routeName = '/admin/campaigns';

  @override
  State<AdminCampaignPage> createState() => _AdminCampaignPageState();
}

class _AdminCampaignPageState extends State<AdminCampaignPage>
    with SingleTickerProviderStateMixin {
  final CampaignController campaignController = Get.put(CampaignController());
  final currencyFormat = NumberFormat.currency(
    symbol: 'KSh ',
    decimalDigits: 0,
  );

  late TabController _tabController;
  final TextEditingController _activeSearchController = TextEditingController();
  final TextEditingController _expiredSearchController =
      TextEditingController();

  String _activeSearchQuery = '';
  String _expiredSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    campaignController.fetchCampaigns();

    // Listen to search changes
    _activeSearchController.addListener(() {
      setState(() {
        _activeSearchQuery = _activeSearchController.text.toLowerCase();
      });
    });

    _expiredSearchController.addListener(() {
      setState(() {
        _expiredSearchQuery = _expiredSearchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _activeSearchController.dispose();
    _expiredSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: const Text(
          'Campaign Management',
          style: TextStyle(
            fontFamily: 'Leotaro',
            color: AppColors.primaryBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accentOrange),
            onPressed: () {
              campaignController.fetchCampaigns();
            },
          ),
          IconButton(
            onPressed: () => _showCampaignReportOptions(context),
            icon: const Icon(Icons.more_vert, color: AppColors.accentOrange),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.accentOrange,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              indicator: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Obx(() {
                    final activeCampaigns = _getActiveCampaigns();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.campaign),
                        const SizedBox(width: 8),
                        const Text('Active'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${activeCampaigns.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                Tab(
                  child: Obx(() {
                    final expiredCampaigns = _getExpiredCampaigns();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy),
                        const SizedBox(width: 8),
                        const Text('Expired'),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${expiredCampaigns.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentOrange,
        onPressed: () {
          Get.to(() => const AdminCampaignCreatePage());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Campaign',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () => campaignController.isLoading.value
            ? const Center(
                child: AnimatedLoadingIndicator(
                  isLoading: true,
                  loadingText: "Loading campaigns...",
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildCampaignTab(
                    campaigns: _getFilteredActiveCampaigns(),
                    searchController: _activeSearchController,
                    emptyMessage: 'No Active Campaigns',
                    emptySubMessage:
                        'Create your first marketing campaign to engage with your audience',
                    isActive: true,
                  ),
                  _buildCampaignTab(
                    campaigns: _getFilteredExpiredCampaigns(),
                    searchController: _expiredSearchController,
                    emptyMessage: 'No Expired Campaigns',
                    emptySubMessage: 'Your expired campaigns will appear here',
                    isActive: false,
                  ),
                ],
              ),
      ),
    );
  }

  List<dynamic> _getActiveCampaigns() {
    return campaignController.campaigns.where((campaign) {
      final DateTime validUntil = campaign.validUntil!;
      return validUntil.isAfter(DateTime.now());
    }).toList();
  }

  List<dynamic> _getExpiredCampaigns() {
    return campaignController.campaigns.where((campaign) {
      final DateTime validUntil = campaign.validUntil!;
      return validUntil.isBefore(DateTime.now());
    }).toList();
  }

  List<dynamic> _getFilteredActiveCampaigns() {
    final activeCampaigns = _getActiveCampaigns();
    if (_activeSearchQuery.isEmpty) return activeCampaigns;

    return activeCampaigns.where((campaign) {
      return campaign.name!.toLowerCase().contains(_activeSearchQuery);
    }).toList();
  }

  List<dynamic> _getFilteredExpiredCampaigns() {
    final expiredCampaigns = _getExpiredCampaigns();
    if (_expiredSearchQuery.isEmpty) return expiredCampaigns;

    return expiredCampaigns.where((campaign) {
      return campaign.name!.toLowerCase().contains(_expiredSearchQuery);
    }).toList();
  }

  Widget _buildCampaignTab({
    required List<dynamic> campaigns,
    required TextEditingController searchController,
    required String emptyMessage,
    required String emptySubMessage,
    required bool isActive,
  }) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.pureWhite,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText:
                  'Search ${isActive ? 'active' : 'expired'} campaigns...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () {
                        searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Campaign List
        Expanded(
          child: campaigns.isEmpty
              ? _buildEmptyState(emptyMessage, emptySubMessage, isActive)
              : RefreshIndicator(
                  color: AppColors.accentOrange,
                  onRefresh: () async {
                    await campaignController.fetchCampaigns();
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return _buildCampaignCard(campaign, isActive);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, String subMessage, bool isActive) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[50] : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.campaign_outlined : Icons.event_busy,
                size: 80,
                color: isActive ? Colors.green[600] : Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(dynamic campaign, bool isActive) {
    final DateTime validUntil = campaign.validUntil!;
    final int daysRemaining = validUntil.difference(DateTime.now()).inDays;

    // Calculate progress based on task completion
    final int totalTasks = (campaign.completed ?? 0) +
        (campaign.ongoing ?? 0) +
        (campaign.available ?? 0);
    final int completedTasks = campaign.completed ?? 0;
    final double progress =
        totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    // Format currency values
    final String formattedBudget = currencyFormat
        .format(double.tryParse(campaign.capitalInvested ?? '0') ?? 0);
    final String formattedReward =
        currencyFormat.format(double.tryParse(campaign.reward ?? '0') ?? 0);
    final String formattedCapacity = campaign.capacity.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isActive
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Get.to(() => AdminCampaignDetailsPage(campaign: campaign));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          isActive ? Icons.campaign : Icons.event_busy,
                          color: isActive ? Colors.green[700] : Colors.red[700],
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.name!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Expired',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isActive
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isActive)
                                Text(
                                  '$daysRemaining days left',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      color: Colors.grey[400],
                      onPressed: () {
                        Get.to(
                            () => AdminCampaignDetailsPage(campaign: campaign));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildInfoItem(
                      icon: Icons.calendar_today,
                      title: 'Valid Until',
                      value: DateFormat('MMM d, yyyy').format(validUntil),
                      flex: 1,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[200],
                    ),
                    _buildInfoItem(
                      icon: Icons.attach_money,
                      title: 'Budget',
                      value: formattedBudget,
                      flex: 1,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoItem(
                      icon: Icons.redeem,
                      title: 'Reward',
                      value: formattedReward,
                      flex: 1,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[200],
                    ),
                    _buildInfoItem(
                      icon: Icons.bar_chart,
                      title: 'Capacity',
                      value: formattedCapacity,
                      flex: 1,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Task Progress',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getProgressColor(progress).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getProgressColor(progress),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(progress),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedTasks of $totalTasks tasks completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTaskStatus(
                            'Completed', campaign.completed ?? 0, Colors.green),
                        const SizedBox(width: 12),
                        _buildTaskStatus(
                            'Ongoing', campaign.ongoing ?? 0, Colors.orange),
                        const SizedBox(width: 12),
                        _buildTaskStatus(
                            'Available', campaign.available ?? 0, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generatePerformanceReport() {
    Get.to(() => const AllCampaignsReport());
  }

  void _showCampaignReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.accentOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campaigns Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generate detailed reports for all campaigns',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () {
                Get.back();
                _generatePerformanceReport();
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              title: const Text(
                'Full Campaigns Report',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Performance, available, ongoing, and engagement',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Colors.grey[400], size: 16),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.accentOrange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatus(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.blue;
    if (progress < 0.7) return AppColors.accentOrange;
    if (progress < 0.9) return Colors.amber[700]!;
    return Colors.green[500]!;
  }
}
