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

  double get progressPercentage {
    const int participants = 10;
    final int capacity = widget.campaign.capacity ?? 1;
    return (participants / capacity).clamp(0.0, 1.0);
  }

  // Added missing property getters
  int get participants => 10;
  int get capacity => widget.campaign.capacity ?? 1;
  double get budget => double.parse(widget.campaign.capitalInvested!) ?? 0.0;
  double get amountSpent => 10.0;
  double get budgetRemaining => budget - amountSpent;
  double get budgetUsagePercentage =>
      budget > 0 ? (amountSpent / budget).clamp(0.0, 1.0) : 0.0;

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
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.redeem, size: 18, color: AppColors.accentOrange),
              const SizedBox(width: 8),
              Text(
                'Reward: KSh ${widget.campaign.reward}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Remaining Budget',
                  value: 'KSh ${numberFormat.format(budgetRemaining)}',
                  icon: Icons.savings,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Participants',
                  value:
                      '${numberFormat.format(participants)}/${numberFormat.format(capacity)}',
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Budget usage progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget Usage',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  Text(
                    '${(budgetUsagePercentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: budgetUsagePercentage > 0.9
                          ? Colors.red[700]
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: budgetUsagePercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  budgetUsagePercentage > 0.9
                      ? Colors.red[400]!
                      : Colors.blue[400]!,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Participants progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Participant Capacity',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  Text(
                    '${(progressPercentage * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: progressPercentage > 0.9
                          ? Colors.red[700]
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressPercentage > 0.9
                      ? Colors.red[400]!
                      : AppColors.accentOrange,
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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

  Widget _buildCampaignStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Budget',
                  value: 'KSh ${numberFormat.format(budget)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Amount Spent',
                  value: 'KSh ${numberFormat.format(amountSpent)}',
                  icon: Icons.money_off,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Remaining Budget',
                  value: 'KSh ${numberFormat.format(budgetRemaining)}',
                  icon: Icons.savings,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Participant Count',
                  value: numberFormat.format(participants),
                  icon: Icons.people,
                  color: Colors.purple,
                ),
              ),
            ],
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
