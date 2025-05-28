import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/product_controller.dart';
import 'package:visible/model/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Datum product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedScreenshot;
  ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedScreenshot = File(image.path);
      });
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.product.imageUrl!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Optional: Add download button in fullscreen view
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Pinch to zoom • Drag to pan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeRemaining() {
    if (widget.product.validUntil != null) {
      final now = DateTime.now();
      final expiry =
          DateTime.parse(widget.product.validUntil!.toIso8601String());
      final difference = expiry.difference(now);

      if (difference.isNegative) return "Expired";

      if (difference.inDays > 0) {
        return "${difference.inDays}d ${difference.inHours % 24}h";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ${difference.inMinutes % 60}m";
      } else {
        return "${difference.inMinutes}m";
      }
    }
    return "No expiry";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.product.name ?? 'Product Details',
          style: const TextStyle(
            fontFamily: 'Leotaro',
            color: AppColors.primaryBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with gradient overlay - Tappable
              GestureDetector(
                onTap: _showImageDialog,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.product.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                    ),
                    // Tap indicator
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to view',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.primaryBlack.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (widget.product.screenshotCount == 5)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.darkBlue.withOpacity(0.05),
                            AppColors.accentOrange.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.darkBlue.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Details',
                            style: TextStyle(
                              fontFamily: 'Leotaro',
                              color: AppColors.primaryBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Reward Amount
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accentOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.monetization_on,
                                  color: AppColors.accentOrange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reward Amount',
                                    style: TextStyle(
                                      fontFamily: 'TT Hoves Pro Trial',
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'KSh ${widget.product.reward ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontFamily: 'Leotaro',
                                      color: AppColors.primaryBlack,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Expiry Information
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.darkBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.schedule,
                                        color: AppColors.darkBlue,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Time Remaining',
                                          style: TextStyle(
                                            fontFamily: 'TT Hoves Pro Trial',
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _getTimeRemaining(),
                                          style: TextStyle(
                                            fontFamily: 'Leotaro',
                                            color:
                                                _getTimeRemaining() == "Expired"
                                                    ? Colors.red
                                                    : AppColors.primaryBlack,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Expiry Date
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.event,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Expires On',
                                    style: TextStyle(
                                      fontFamily: 'TT Hoves Pro Trial',
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    widget.product.validUntil != null
                                        ? DateFormat('dd MMM yyyy, hh:mm a')
                                            .format(DateTime.parse(widget
                                                .product.validUntil
                                                .toString()))
                                        : 'No expiry date',
                                    style: const TextStyle(
                                      fontFamily: 'Leotaro',
                                      color: AppColors.primaryBlack,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                    const SizedBox(height: 24),

                    // Step 1: Download
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
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
                          const Text(
                            'Step 1: Download and Share',
                            style: TextStyle(
                              fontFamily: 'Leotaro',
                              color: AppColors.primaryBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Download this product image and share it on your WhatsApp status to earn rewards.',
                            style: TextStyle(
                              fontFamily: 'TT Hoves Pro Trial',
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: productController.isDownloading.value
                                  ? null
                                  : () => productController.downloadImage(
                                      widget.product.downloadUrl!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                foregroundColor: AppColors.pureWhite,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: productController.isDownloading.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download),
                              label: Text(
                                productController.isDownloading.value
                                    ? 'Downloading...'
                                    : 'Download Image',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                    const SizedBox(height: 24),

                    // Step 2: Verification section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
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
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Step 2: Upload Screenshot for Verification',
                                  style: TextStyle(
                                    fontFamily: 'Leotaro',
                                    color: AppColors.primaryBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (widget.product.screenshotId != null)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Take a screenshot of your WhatsApp status showing this product and upload it here to verify your share.',
                            style: TextStyle(
                              fontFamily: 'TT Hoves Pro Trial',
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedScreenshot != null &&
                              widget.product.screenshotId == null)
                            Container(
                              width: double.infinity,
                              height: 150,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(_selectedScreenshot!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (widget.product.screenshotCount != 5)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickScreenshot,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      foregroundColor: AppColors.primaryBlack,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Choose Screenshot'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Obx(
                                  () => Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: productController
                                                  .isUploading.value ||
                                              _selectedScreenshot == null
                                          ? null
                                          : () async => await productController
                                              .uploadProductScreenShot(
                                                  imageFile:
                                                      _selectedScreenshot!,
                                                  productId: widget.product.id!,
                                                  isCompleted: widget.product
                                                              .screenshotCount ==
                                                          4
                                                      ? true
                                                      : false,
                                                  isOngoing: widget.product
                                                                  .screenshotCount ==
                                                              0 ||
                                                          widget.product
                                                                  .screenshotCount! <=
                                                              4
                                                      ? true
                                                      : false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accentOrange,
                                        foregroundColor: AppColors.pureWhite,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: productController.isUploading.value
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.upload),
                                      label: Text(
                                        productController.isUploading.value
                                            ? 'Uploading...'
                                            : 'Verify',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: AppColors.pureWhite,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Verified'),
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                    // Add bottom padding to account for system navigation
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
