import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/product_controller.dart';
import 'package:visible/model/product_model.dart';
import 'package:visible/screens/user/products/product_detail_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  static const routeName = '/products';

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int _selectedCategory = 0;
  final bool _isVerifying = false;
  int? _currentVerifyingProductId;
  ProductController productController = Get.put(ProductController());

  // Mock categories
  final List<String> _categories = [
    'All',
    'Trending',
    'New',
    'Fashion',
    'Electronics',
    'Home'
  ];

  Future _shareToWhatsAppStatus(Datum product) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.accentOrange,
          ),
        ),
        barrierDismissible: false,
      );

      final imageFile =
          await productController.downloadImage(product.downloadUrl!);

      if (imageFile == null) {
        throw Exception("Image couldn't be downloaded");
      }

      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text:
            'Check out this product: ${product.category}\n${product.createdAt!}\n\nShared via Visible App',
        sharePositionOrigin: Rect.zero,
      );

      _showVerificationDialog(product);
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to share product. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showVerificationDialog(Datum product) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Verify Your Share',
          style: TextStyle(
            fontFamily: 'Leotaro',
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please take a screenshot of your WhatsApp status showing this product and upload it here to earn your reward.',
              style: TextStyle(
                fontFamily: 'TT Hoves Pro Trial',
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(ProductDetailPage(product: product)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: AppColors.pureWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Upload Screenshot'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  'I\'ll do this later',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    productController.fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: const Text(
          'Share & Earn',
          style: TextStyle(
            fontFamily: 'Leotaro',
            color: AppColors.primaryBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.primaryBlack),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories horizontal list
          Container(
            color: AppColors.pureWhite,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: List.generate(
                  _categories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedCategory == index
                              ? AppColors.accentOrange
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedCategory == index
                                ? AppColors.accentOrange
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            fontFamily: 'TT Hoves Pro Trial',
                            color: _selectedCategory == index
                                ? AppColors.pureWhite
                                : AppColors.primaryBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(
              begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),

          // Products grid
          Obx(
            () => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: productController.productsList.length,
                  itemBuilder: (context, index) {
                    Datum product = productController.productsList[index];
                    final bool isCurrentlyVerifying = _isVerifying &&
                        _currentVerifyingProductId == product.id;

                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ProductDetailPage(product: product));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            Expanded(
                              child: Stack(
                                children: [
                                  // Image container
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(product.imageUrl!),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) =>
                                            const Icon(
                                                Icons.image_not_supported),
                                      ),
                                    ),
                                  ),

                                  if (product.screenshotUrl != null)
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                              'Verified',
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

                            // Product info
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.category!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Leotaro',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Reward: Ksh 20',
                                    style: TextStyle(
                                      color: AppColors.accentOrange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _shareToWhatsAppStatus(product),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            product.screenshotUrl != null
                                                ? Colors.grey
                                                : AppColors.accentOrange,
                                        foregroundColor: AppColors.pureWhite,
                                        disabledBackgroundColor: Colors.grey,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        product.screenshotUrl != null
                                            ? 'Shared'
                                            : 'Share Now',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: Duration(milliseconds: 100 * index),
                          )
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            duration: 300.ms,
                            delay: Duration(milliseconds: 100 * index),
                            curve: Curves.easeOut,
                          ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
