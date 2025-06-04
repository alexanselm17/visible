import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/campaign_controller.dart';
import 'package:visible/controller/product_controller.dart';
import 'package:visible/model/campaign/campaign_product.dart' as prod;
import 'package:visible/model/campaign/campaign_model.dart';
import 'package:visible/screens/admin/add_new_product.dart';
import 'package:visible/screens/admin/campaign/edit_campaign.dart';
import 'package:visible/screens/reports/specific_campaign_report.dart';
import 'package:visible/widgets/loading_indicator.dart';

class AdminCampaignDetailsPage extends StatefulWidget {
  final Datum campaign;

  const AdminCampaignDetailsPage({super.key, required this.campaign});

  @override
  State<AdminCampaignDetailsPage> createState() =>
      _AdminCampaignDetailsPageState();
}

class _AdminCampaignDetailsPageState extends State<AdminCampaignDetailsPage> {
  final CampaignController campaignController = Get.find<CampaignController>();
  final ProductController productController = Get.put(ProductController());
  final numberFormat = NumberFormat('#,###');
  final currencyFormat = NumberFormat.currency(
    symbol: 'KSh ',
    decimalDigits: 0,
  );
  final dateFormat = DateFormat('MMM d, yyyy');

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await campaignController.fetchCampaignProducts(
          campaignId: widget.campaign.id!, isRefresh: true);
    });
  }

  bool get isActive {
    final DateTime validUntil = widget.campaign.validUntil!;
    return validUntil.isAfter(DateTime.now());
  }

  // Fixed analytics calculations matching the campaign list page
  int get totalTasks =>
      (widget.campaign.completed ?? 0) +
      (widget.campaign.ongoing ?? 0) +
      (widget.campaign.available ?? 0);

  int get completedTasks => widget.campaign.completed ?? 0;
  int get ongoingTasks => widget.campaign.ongoing ?? 0;
  int get availableTasks => widget.campaign.available ?? 0;

  double get taskProgress =>
      totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

  double get budget =>
      double.tryParse(widget.campaign.capitalInvested ?? '0') ?? 0.0;
  double get reward => double.tryParse(widget.campaign.reward ?? '0') ?? 0.0;
  int get capacity => widget.campaign.capacity ?? 0;

  // Calculate days remaining
  int get daysRemaining {
    final DateTime validUntil = widget.campaign.validUntil!;
    return validUntil.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: const Text(
          'Campaign Details',
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
          // Report button in app bar
          IconButton(
            icon: const Icon(Icons.analytics, color: AppColors.primaryBlack),
            onPressed: () => _showCampaignReportOptions(context),
            tooltip: 'Generate Report',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryBlack),
            onPressed: () {
              Get.to(() => AdminCampaignEditPage(campaign: widget.campaign));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentOrange,
        onPressed: () {
          Get.to(
              () => AdminProductEditPage(
                    campaignId: widget.campaign.id!,
                  ),
              arguments: {"campaignId": widget.campaign.id});
        },
        tooltip: 'Add Product to Campaign',
        child: const Icon(Icons.add_shopping_cart, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCampaignHeader(),
            const SizedBox(height: 16),
            _buildCampaignStats(),
            const SizedBox(height: 16),
            _buildCampaignProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.campaign.name!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Expired',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 18, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Valid until: ${dateFormat.format(widget.campaign.validUntil!)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryBlack,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 16),
                Text(
                  '($daysRemaining days left)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.redeem, size: 18, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Reward: ${currencyFormat.format(reward)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task Progress Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(taskProgress).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(taskProgress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(taskProgress),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: taskProgress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  minHeight: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(taskProgress),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTaskStatus('Completed', completedTasks, Colors.green),
                  const SizedBox(width: 12),
                  _buildTaskStatus('Ongoing', ongoingTasks, Colors.orange),
                  const SizedBox(width: 12),
                  _buildTaskStatus('Available', availableTasks, Colors.blue),
                ],
              ),
            ],
          ),
        ],
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

  Widget _buildCampaignStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Campaign Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              // Alternative report button location in stats section
              OutlinedButton.icon(
                onPressed: () => _showCampaignReportOptions(context),
                icon: const Icon(Icons.analytics, size: 18),
                label: const Text('Report'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentOrange,
                  side: const BorderSide(color: AppColors.accentOrange),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Budget',
                  value: currencyFormat.format(budget),
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Reward Amount',
                  value: currencyFormat.format(reward),
                  icon: Icons.redeem,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Capacity',
                  value: numberFormat.format(capacity),
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Days Remaining',
                  value: isActive ? '$daysRemaining days' : 'Expired',
                  icon: Icons.timer,
                  color: isActive
                      ? (daysRemaining <= 7 ? Colors.red : Colors.orange)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Campaign Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Get.to(
                    () => AdminProductEditPage(
                      campaignId: widget.campaign.id!,
                    ),
                  );
                },
                icon: const Icon(Icons.add,
                    size: 18, color: AppColors.accentOrange),
                label: const Text(
                  'Add Product',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => campaignController.isLoading.value
                ? const Center(
                    child: AnimatedLoadingIndicator(
                      isLoading: true,
                      loadingText: "Loading products...",
                    ),
                  )
                : campaignController.productsInCampaign.isEmpty
                    ? _buildEmptyProductsState()
                    : _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProductsState() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products in this campaign yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to showcase in this campaign',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(
                () => AdminProductEditPage(
                  campaignId: widget.campaign.id!,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: campaignController.productsInCampaign.length,
      itemBuilder: (context, index) {
        prod.Datum product = campaignController.productsInCampaign[index];
        return _buildProductCard(product);
      },
    );
  }

  // Updated report options for campaign-specific reports
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
                        'Campaign Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Generate detailed reports for this campaign',
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
                'Full Report',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Performance, tasks, and engagement',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: Colors.grey[400], size: 16),
            ),

            const SizedBox(height: 8),

            // // Financial Report Option
            // ListTile(
            //   onTap: () {
            //     Get.back();
            //     _generateFinancialReport();
            //   },
            //   leading: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.green.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Icon(
            //       Icons.account_balance_wallet_rounded,
            //       color: Colors.green[700],
            //       size: 20,
            //     ),
            //   ),
            //   title: const Text(
            //     'Financial Report',
            //     style: TextStyle(fontWeight: FontWeight.w600),
            //   ),
            //   subtitle: Text(
            //     'Budget utilization, rewards distributed',
            //     style: TextStyle(color: Colors.grey[600], fontSize: 12),
            //   ),
            //   trailing: Icon(Icons.arrow_forward_ios,
            //       color: Colors.grey[400], size: 16),
            // ),

            // const SizedBox(height: 8),

            // // Product Report Option
            // ListTile(
            //   onTap: () {
            //     Get.back();
            //     _generateProductReport();
            //   },
            //   leading: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.purple.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Icon(
            //       Icons.inventory_rounded,
            //       color: Colors.purple[700],
            //       size: 20,
            //     ),
            //   ),
            //   title: const Text(
            //     'Product Report',
            //     style: TextStyle(fontWeight: FontWeight.w600),
            //   ),
            //   subtitle: Text(
            //     'Product performance and engagement',
            //     style: TextStyle(color: Colors.grey[600], fontSize: 12),
            //   ),
            //   trailing: Icon(Icons.arrow_forward_ios,
            //       color: Colors.grey[400], size: 16),
            // ),
          ],
        ),
      ),
    );
  }

  void _generatePerformanceReport() {
    Get.to(() => CampaignReportPage(campaignId: widget.campaign.id!));
  }

  void _generateFinancialReport() {
    // Navigate to financial report page or generate report
    // Get.to(() => CampaignFinancialReport(campaign: widget.campaign));
    Get.snackbar(
      'Report',
      'Generating financial report...',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );
  }

  void _generateProductReport() {
    // Navigate to product report page or generate report
    // Get.to(() => CampaignProductReport(campaign: widget.campaign));
    Get.snackbar(
      'Report',
      'Generating product report...',
      backgroundColor: Colors.purple[100],
      colorText: Colors.purple[800],
    );
  }

  Widget _buildProductCard(prod.Datum product) {
    return InkWell(
      onTap: () {
        Get.to(() => AdminProductEditPage(
            product: product, campaignId: widget.campaign.id!));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: product.imageUrl != null
                        ? NetworkImage(product.imageUrl!)
                        : const AssetImage('assets/images/placeholder.png')
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Unnamed Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primaryBlack,
                    ),
                    maxLines: 1,
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
}
