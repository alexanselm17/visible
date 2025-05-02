import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/product_controller.dart';
import 'package:visible/model/campaign/campaign_product.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminProductEditPage extends StatefulWidget {
  final Datum? product;
  final String campaignId;

  const AdminProductEditPage(
      {super.key, required this.campaignId, this.product});

  @override
  State<AdminProductEditPage> createState() => _AdminProductEditPageState();
}

class _AdminProductEditPageState extends State<AdminProductEditPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  String? _existingImageUrl;
  bool _imageChanged = false;

  final TextEditingController _nameController = TextEditingController();
  bool get isEditing => widget.product != null;
  ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _nameController.text = widget.product!.name!;
      if (widget.product!.imageUrl != null) {
        _existingImageUrl = widget.product!.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
          _imageChanged = true;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      );
    } else if (isEditing && _existingImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: _existingImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: AppColors.accentOrange),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    }
    // Default placeholder
    else {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Tap to select product image',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a product name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isEditing) {
      // if (_imageChanged && _selectedImageFile != null) {
      //   await productController.updateProductAdvert(
      //     productId: widget.product!.id!,
      //     campaignId: widget.campaignId,
      //     imageFile: _selectedImageFile,
      //     name: _nameController.text,
      //   );
      // } else {
      //   await productController.updateProductAdvert(
      //     productId: widget.product!.id!,
      //     campaignId: widget.campaignId,
      //     name: _nameController.text,
      //   );
      // }
    } else {
      // Handle create scenario
      if (_selectedImageFile == null) {
        Get.snackbar(
          'Error',
          'Please select a product image',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await productController.uploadProductAdvert(
        campaignId: widget.campaignId,
        imageFile: _selectedImageFile!,
        name: _nameController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 24),

            // Product Details Form
            const Text(
              'Product Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 10),

            // Product Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                hintText: 'Enter product name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Obx(
              () => productController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentOrange))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update Product' : 'Create Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
