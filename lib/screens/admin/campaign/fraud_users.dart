import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:visible/controller/campaign_controller.dart';
import 'package:visible/model/campaign/fraud.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FraudUsers extends StatefulWidget {
  final String campaignId;
  final String? campaignName;
  const FraudUsers({super.key, required this.campaignId, this.campaignName});

  @override
  State<FraudUsers> createState() => _FraudUsersState();
}

class _FraudUsersState extends State<FraudUsers> {
  CampaignController campaignController = Get.find<CampaignController>();

  // App colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFFF7F00);

  @override
  void initState() {
    campaignController.fetchFraudInCampaign(campaignId: widget.campaignId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fraud Detection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (widget.campaignName != null)
              Text(
                widget.campaignName!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Obx(() {
          if (campaignController.isLoading.value) {
            return _buildLoadingState();
          }

          final fraudData = campaignController.fraudUserModel.value;

          if (fraudData?.fraudGroups == null ||
              fraudData!.fraudGroups!.isEmpty) {
            return _buildNoFraudState();
          }

          return _buildFraudDetectedState(fraudData);
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing fraud patterns...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFraudState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: Colors.green[100]!, width: 2),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 60,
              color: Colors.green[500],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All Clear!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No fraudulent activity detected',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This campaign appears to be legitimate',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFraudDetectedState(FraudUserModel fraudData) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: fraudData.fraudGroups!.length,
            itemBuilder: (context, index) {
              final fraudGroup = fraudData.fraudGroups![index];
              return _buildFraudGroupCard(fraudGroup, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFraudGroupCard(FraudGroup fraudGroup, int groupNumber) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: const Border(
            left: BorderSide(color: accentOrange, width: 4),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: false,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accentOrange.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '$groupNumber',
                  style: const TextStyle(
                    color: accentOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              'Suspicious Group $groupNumber',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF2D2D2D),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fraudGroup.advertId != null)
                    _buildInfoRow(
                        Icons.campaign, 'Ad ID: ${fraudGroup.advertId}'),
                  if (fraudGroup.matchingViewsTimestamp != null)
                    _buildInfoRow(Icons.access_time,
                        'Time: ${_formatTimestamp(fraudGroup.matchingViewsTimestamp!)}'),
                  _buildInfoRow(Icons.group,
                      '${fraudGroup.details?.length ?? 0} users flagged'),
                ],
              ),
            ),
            children: [
              if (fraudGroup.details != null && fraudGroup.details!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: accentOrange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Flagged Users',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...fraudGroup.details!
                          .map((detail) => _buildUserCard(detail)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Detail detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildUserAvatar(detail),
          const SizedBox(width: 16),
          Expanded(
            child: _buildUserInfo(detail),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(Detail detail) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: detail.url != null && detail.url!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: detail.url!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _buildDefaultAvatar(detail),
              )
            : _buildDefaultAvatar(detail),
      ),
    );
  }

  Widget _buildDefaultAvatar(Detail detail) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            accentOrange.withOpacity(0.8),
            accentOrange,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          detail.name?.isNotEmpty == true
              ? detail.name!.substring(0, 1).toUpperCase()
              : 'U',
          style: const TextStyle(
            color: pureWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(Detail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail.name ?? 'Unknown User',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 6),
        if (detail.userId != null)
          _buildUserInfoItem(
            Icons.fingerprint,
            'ID: ${detail.userId}',
            Colors.grey[600]!,
          ),
        if (detail.views != null)
          _buildUserInfoItem(
            Icons.visibility,
            '${detail.views} views',
            accentOrange,
          ),
        if (detail.timestamp != null)
          _buildUserInfoItem(
            Icons.schedule,
            'Last: ${_formatTimestamp(detail.timestamp!)}',
            Colors.grey[600]!,
          ),
      ],
    );
  }

  Widget _buildUserInfoItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight:
                    color == accentOrange ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFraudBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4757).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF4757).withOpacity(0.3),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: 16,
            color: Color(0xFFFF4757),
          ),
          SizedBox(width: 4),
          Text(
            'FRAUD',
            style: TextStyle(
              color: Color(0xFFFF4757),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
