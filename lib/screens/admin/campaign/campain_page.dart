import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visible/controller/campaign_controller.dart';
import 'package:visible/model/campaign/campaign_model.dart';
import 'package:visible/screens/admin/campaign/add_product.dart';
import 'package:visible/screens/admin/campaign/campaign_detail.dart';
import 'package:visible/screens/admin/campaign/create_campaign.dart';

class AdminCampaignPage extends StatefulWidget {
  const AdminCampaignPage({super.key});

  @override
  State<AdminCampaignPage> createState() => _AdminCampaignPageState();
}

class _AdminCampaignPageState extends State<AdminCampaignPage> {
  static const Color accentOrange = Color(0xFFFF7F00);

  bool isLoading = true;
  String? errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final CampaignController campaignController = Get.put(CampaignController());

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await campaignController.fetchCampaigns();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load campaigns: ${e.toString()}';
      });
    }
  }

  List<Datum> get filteredCampaigns {
    final campaigns = campaignController.campaigns;
    if (_searchQuery.isEmpty) return campaigns;

    return campaigns.where((campaign) {
      final name = campaign.name?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Campaigns',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCampaigns,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Summary Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: accentOrange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Summary Stats
                if (!isLoading && errorMessage == null) _buildSummaryRow(),
              ],
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCampaigns,
              color: accentOrange,
              child: _buildContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        onPressed: () {
          Get.to(() => const AdminCampaignCreatePage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingState();
    } else if (errorMessage != null) {
      return _buildErrorState();
    } else if (filteredCampaigns.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildCampaignsList();
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
          ),
          SizedBox(height: 16),
          Text(
            'Loading campaigns...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Failed to load campaigns',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCampaigns,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.campaign_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No campaigns found'
                  : 'No campaigns yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Create your first campaign to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const AdminCampaignCreatePage());
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Campaign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    int totalCompleted = campaignController.campaigns
        .fold(0, (sum, campaign) => sum + (campaign.completed ?? 0));
    int totalOngoing = campaignController.campaigns
        .fold(0, (sum, campaign) => sum + (campaign.ongoing ?? 0));
    int totalRewards = campaignController.campaigns
        .fold(0, (sum, campaign) => sum + (campaign.totalRewardsGiven ?? 0));

    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Total',
            '${campaignController.campaigns.length}',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            'Completed',
            '$totalCompleted',
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            'Ongoing',
            '$totalOngoing',
            accentOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            'Rewards',
            NumberFormat.compact().format(totalRewards),
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = filteredCampaigns[index];
        return _buildCampaignCard(campaign);
      },
    );
  }

  Widget _buildCampaignCard(Datum campaign) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => AdminCampaignDetailsPage(campaignId: campaign.id!));
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.name ?? 'Unnamed Campaign',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editCampaign(campaign);
                          break;
                        case 'delete':
                          _deleteCampaign(campaign);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  _buildStatChip(
                    'Completed',
                    '${campaign.completed ?? 0}',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    'Ongoing',
                    '${campaign.ongoing ?? 0}',
                    accentOrange,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    'Available',
                    '${campaign.available ?? 0}',
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Rewards: ${NumberFormat.compact().format(campaign.totalRewardsGiven ?? 0)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (campaign.createdAt != null)
                    Text(
                      DateFormat('MMM dd, yyyy').format(campaign.createdAt!),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _editCampaign(Datum campaign) {
    // Navigate to edit campaign page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit campaign functionality coming soon')),
    );
  }

  void _deleteCampaign(Datum campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: Text('Are you sure you want to delete "${campaign.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                campaignController.campaigns.remove(campaign);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Campaign "${campaign.name}" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
