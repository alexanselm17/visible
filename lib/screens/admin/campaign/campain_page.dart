import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/campaign_controller.dart';
import 'package:visible/screens/admin/campaign/campaign_detail.dart';
import 'package:visible/screens/admin/campaign/create_campaign.dart';

class AdminCampaignPage extends StatefulWidget {
  const AdminCampaignPage({super.key});

  static const routeName = '/admin/campaigns';

  @override
  State<AdminCampaignPage> createState() => _AdminCampaignPageState();
}

class _AdminCampaignPageState extends State<AdminCampaignPage> {
  final CampaignController campaignController = Get.put(CampaignController());
  final currencyFormat = NumberFormat.currency(
    symbol: 'KSh ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    campaignController.fetchCampaigns();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 1,
        title: const Text(
          'Campaign Management',
          style: TextStyle(
            fontFamily: 'Leotaro',
            color: AppColors.primaryBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accentOrange),
            onPressed: () {
              campaignController.fetchCampaigns();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentOrange,
        onPressed: () {
          Get.to(() => const AdminCampaignCreatePage());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Campaign',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Obx(
        () => campaignController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accentOrange),
              )
            : campaignController.campaigns.isEmpty
                ? _buildEmptyState()
                : _buildCampaignList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign_outlined,
                  size: 80, color: AppColors.accentOrange),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Campaigns',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first marketing campaign to engage with your audience',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => const AdminCampaignCreatePage());
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Campaign'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignList() {
    return RefreshIndicator(
      color: AppColors.accentOrange,
      onRefresh: () async {
        await campaignController.fetchCampaigns();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: campaignController.campaigns.length,
        itemBuilder: (context, index) {
          final campaign = campaignController.campaigns[index];
          final DateTime validUntil = campaign.validUntil!;
          final bool isActive = validUntil.isAfter(DateTime.now());

          // Calculate days remaining
          final int daysRemaining =
              validUntil.difference(DateTime.now()).inDays;

          // Calculate progress
          final double progress = campaign.capitalInvested != null &&
                  campaign.capacity != null
              ? (double.parse(campaign.capitalInvested!) / campaign.capacity!)
              : 0.0;

          // Format currency values
          final String formattedBudget = currencyFormat
              .format(double.tryParse(campaign.capitalInvested ?? '0') ?? 0);
          final String formattedReward = currencyFormat
              .format(double.tryParse(campaign.reward ?? '0') ?? 0);
          final String formattedCapacity = currencyFormat
              .format(double.tryParse(campaign.capacity.toString()) ?? 0);

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
                  Get.to(
                    () => AdminCampaignDetailsPage(campaign: campaign),
                  );
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
                              color:
                                  isActive ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                isActive ? Icons.campaign : Icons.event_busy,
                                color: isActive
                                    ? Colors.green[700]
                                    : Colors.red[700],
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
                              Get.to(() =>
                                  AdminCampaignDetailsPage(campaign: campaign));
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
                                'Campaign Progress',
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
                                  color: _getProgressColor(progress)
                                      .withOpacity(0.1),
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
                            '$formattedBudget of $formattedCapacity',
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
              ),
            ),
          );
        },
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

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.blue;
    if (progress < 0.7) return AppColors.accentOrange;
    if (progress < 0.9) return Colors.amber[700]!;
    return Colors.red[500]!;
  }
}
