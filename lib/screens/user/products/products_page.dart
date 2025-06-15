import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
              color: isSelected ? AppColors.accentOrange : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          categoryName,
          style: TextStyle(
            fontFamily: 'TT Hoves Pro Trial',
            color: isSelected ? AppColors.accentOrange : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Datum product, int index) {
    switch (_selectedCategory) {
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

  // Build the content for each tab
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
                                ? 'No products in progress'
                                : 'No completed products',
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl!),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name!.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Leotaro',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildBadge('EXECUTIVE', Colors.green),
                      if (product.category?.contains('luxury') == true ||
                          product.name!.toLowerCase().contains('cognac') ||
                          product.name!.toLowerCase().contains('walker'))
                        _buildBadge('LUXURY', Colors.purple),
                      if (product.name!.toLowerCase().contains('cognac') ||
                          product.name!.toLowerCase().contains('walker'))
                        _buildBadge('NSFW', Colors.red),
                      if (index == 0) _buildBadge('BADGE 2', Colors.red),
                    ],
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
                    'The ${product.name} is a premium product that offers exceptional quality and value. It is designed to meet the highest standards of excellence and provide an unparalleled experience.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ksh ${product.reward ?? 50}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Expires in ${_getRemainingTime(product.validUntil)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
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
    );
  }

  Widget _buildOngoingProductCard(Datum product, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailPage(product: product));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              width: 150,
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl!),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) =>
                      const Icon(Icons.image_not_supported),
                ),
              ),
            ),

            // const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name!.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Leotaro',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Circle
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${product.screenshotCount ?? 3}/5',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price and Time Row
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ksh ${product.reward ?? 50}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in ${_getRemainingTime(product.validUntil)}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardAndTimeInfo(Datum product, bool isCompleted) {
    final remainingTime = _getRemainingTime(product.validUntil);
    final timeColor = _getTimeColor(product.validUntil);

    return Column(
      children: [
        // Reward Info
        Row(
          children: [
            const Icon(
              Icons.monetization_on,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Reward KSH ${product.reward ?? 0}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.accentOrange,
              ),
            ),
            // Time Info
          ],
        ),
        if (!isCompleted)
          Row(
            children: [
              const Icon(
                Icons.timer,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                "Expires in $remainingTime",
                style: TextStyle(
                  fontSize: 12,
                  color: timeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCompletedProductCard(Datum product, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductAnalyticsPage(product: product));
      },
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl!),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Leotaro',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRewardAndTimeInfo(product, true),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reward Earned',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null, // Disabled for completed items
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
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
        text,
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
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(0),
                ),
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(const ProfilePage()),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authenticationController.currentUser.value.username ??
                              'User',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          authenticationController.currentUser.value.fullname ??
                              'Full Name',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
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
