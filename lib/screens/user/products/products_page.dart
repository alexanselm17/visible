import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:visible/common/notif_icon.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/controller/product_controller.dart';
import 'package:visible/model/product_model.dart';
import 'package:visible/screens/profile_page.dart';
import 'package:visible/screens/user/products/completed_product.dart';
import 'package:visible/screens/user/products/product_detail_page.dart';
import 'package:visible/widgets/loading_indicator.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  static const routeName = '/products';

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int _selectedCategory = 0;
  ProductController productController = Get.put(ProductController());
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  // Add PageController for swipe functionality
  late PageController _pageController;

  // Filter categories with their keys
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Available', 'key': 'available'},
    {'name': 'Ongoing', 'key': 'ongoing'},
    {'name': 'Completed', 'key': 'completed'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedCategory);
    productController.fetchProductsByFilter(filter: _categories[0]['key']);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Get current filter key
  String get currentFilter => _categories[_selectedCategory]['key'];

  // Get current products list
  RxList<Datum> get currentProductsList =>
      productController.getCurrentList(currentFilter);

  // Get current loading state
  RxBool get currentLoadingState =>
      productController.getLoadingState(currentFilter);

  // Helper method to calculate remaining time
  String _getRemainingTime(DateTime? validUntil) {
    if (validUntil == null) return 'No expiry';

    final now = DateTime.now();
    final difference = validUntil.difference(now);

    if (difference.isNegative) return 'Expired';

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Helper method to get time color based on urgency
  Color _getTimeColor(DateTime? validUntil) {
    if (validUntil == null) return Colors.grey;

    final now = DateTime.now();
    final difference = validUntil.difference(now);

    if (difference.isNegative) return Colors.red;

    final hoursLeft = difference.inHours;
    if (hoursLeft <= 24) return Colors.red;
    if (hoursLeft <= 72) return Colors.orange;
    return Colors.green;
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _selectedCategory = index;
    });

    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Fetch products for selected filter
    String filterKey = _categories[index]['key'];
    productController.fetchProductsByFilter(filter: filterKey);
  }

  // Handle page view changes (when user swipes)
  void _onPageChanged(int index) {
    setState(() {
      _selectedCategory = index;
    });

    // Fetch products for selected filter
    String filterKey = _categories[index]['key'];
    productController.fetchProductsByFilter(filter: filterKey);
  }

  Widget _buildCategoryTab(int index) {
    bool isSelected = _selectedCategory == index;
    String categoryName = _categories[index]['name'];
    String filterKey = _categories[index]['key'];

    // Get count for badge
    int count = 0;
    switch (filterKey) {
      case 'available':
        count = productController.availableCount;
        break;
      case 'ongoing':
        count = productController.progressCount;
        break;
      case 'completed':
        count = productController.completedCount;
        break;
    }

    return GestureDetector(
      onTap: () => _onCategoryChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.pureWhite : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    String filterKey = _categories[tabIndex]['key'];
    RxList<Datum> productsList = productController.getCurrentList(filterKey);
    RxBool loadingState = productController.getLoadingState(filterKey);

    return Obx(
      () => loadingState.value
          ? const Center(
              child: AnimatedLoadingIndicator(
                isLoading: true,
                loadingText: "Loading products...",
              ),
            )
          : productsList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabIndex == 0
                            ? Icons.inventory_2_outlined
                            : tabIndex == 1
                                ? Icons.hourglass_empty
                                : Icons.check_circle_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tabIndex == 0
                            ? 'No available products'
                            : tabIndex == 1
                                ? 'No campaign in progress'
                                : 'No completed campaigns',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productsList.length,
                  itemBuilder: (context, index) {
                    Datum product = productsList[index];
                    return Column(
                      children: [
                        _buildProductCardForTab(product, index, tabIndex),
                        if (index < productsList.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Container(
                              height: 2,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 10),
                            ),
                          ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildProductCardForTab(Datum product, int index, int tabIndex) {
    switch (tabIndex) {
      case 0: // Available
        return _buildAvailableProductCard(product, index);
      case 1: // Ongoing
        return _buildOngoingProductCard(product, index);
      case 2: // Completed
        return _buildCompletedProductCard(product, index);
      default:
        return _buildAvailableProductCard(product, index);
    }
  }

  Widget _buildAvailableProductCard(Datum product, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailPage(product: product));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image Container
              Container(
                height: 200,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  image:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/johnnie_walker.png'),
                              fit: BoxFit.cover,
                            ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      (product.name ?? 'Product Name').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    if (product.badge != null && product.badge!.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: product.badge!.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final String badge = entry.value;
                          final Color badgeColor = AppColors.badgeColors[
                              index % AppColors.badgeColors.length];

                          return _buildBadge(badge, badgeColor);
                        }).toList(),
                      ),

                    const SizedBox(height: 12),

                    Text(
                      'Description:',
                      style: TextStyle(
                        color: Colors.orange[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      product.description ?? 'No description available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Price Row with overflow protection
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Ksh ${product.reward ?? 50}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Timer Row with overflow protection
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _getRemainingTime(product.validUntil) == 'Expired'
                                ? 'Expired'
                                : 'Expires in ${_getRemainingTime(product.validUntil)}',
                            style: TextStyle(
                              color: _getRemainingTime(product.validUntil) ==
                                      'Expired'
                                  ? Colors.red
                                  : Colors.orange,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingProductCard(Datum product, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailPage(product: product));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image Container
              Container(
                height: 200,
                width: 125,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  image:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/johnnie_walker.png'),
                              fit: BoxFit.cover,
                            ),
                ),
              ),

              const SizedBox(width: 16),

              // Content Column - Expanded to prevent overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Product Name - Fixed with proper text handling
                    Text(
                      product.name ?? "Product Name",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Progress Circle
                    Center(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                value: (double.parse(
                                        product.screenshotCount.toString()) /
                                    2.0),
                                strokeWidth: 3,
                                backgroundColor: Colors.black.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                            Text(
                              '${product.screenshotCount}/2',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Price Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Ksh ${product.reward ?? 50}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Time Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _getRemainingTime(product.validUntil) == 'Expired'
                                ? 'Expired'
                                : 'Expires in ${_getRemainingTime(product.validUntil)}',
                            style: TextStyle(
                              color: _getRemainingTime(product.validUntil) ==
                                      'Expired'
                                  ? Colors.red
                                  : Colors.orange,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedProductCard(Datum product, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductAnalyticsPage(product: product));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 140,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  product.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name?.toUpperCase() ?? '',
                      softWrap: true, // Wrap text
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C851),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          title: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.to(const ProfilePage()),
                  child: Obx(
                    () => Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              children: [
                                Image.asset(
                                  authenticationController
                                              .currentUser.value.gender ==
                                          'Male'
                                      ? 'assets/images/boy.png'
                                      : 'assets/images/girl.jpg',
                                  height: 42,
                                  width: 42,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.05),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(60),
                                      onTap: () => Get.to(const ProfilePage()),
                                      splashColor:
                                          Colors.white.withOpacity(0.3),
                                      highlightColor:
                                          Colors.white.withOpacity(0.1),
                                      child: Container(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => Text(
                          authenticationController
                                      .currentUser.value.username?.isNotEmpty ==
                                  true
                              ? authenticationController
                                  .currentUser.value.username!
                              : 'Username',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          authenticationController
                                      .currentUser.value.fullname?.isNotEmpty ==
                                  true
                              ? authenticationController
                                  .currentUser.value.fullname!
                              : 'Full Name',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
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
                buildNotificationIconAlt(),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _categories.length,
                    (index) => _buildCategoryTab(index),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return _buildTabContent(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
