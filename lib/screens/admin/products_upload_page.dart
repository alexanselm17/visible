import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/screens/admin/add_new_product.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  static const routeName = '/admin/products';

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final bool _isLoading = false;

  // Mock products data - in a real app, this would come from a database
  final RxList<Map<String, dynamic>> _products = [
    {
      'id': 1,
      'name': 'Limited Edition Sneakers',
      'description':
          'Exclusive sneakers with unique design. Share now for special offers!',
      'image': 'assets/images/Glowify-gallery-img-1.png',
      'category': 'Fashion',
      'isVerified': false,
      'reward': 'Ksh 50 Cashback',
    },
    {
      'id': 2,
      'name': 'Smart Watch Pro',
      'description':
          'Track your fitness and stay connected with this premium smartwatch.',
      'image': 'assets/images/668adc4fcd57736f5c718ef9_product-18.png',
      'category': 'Electronics',
      'isVerified': false,
      'reward': 'Ksh 100 Discount',
    },
    {
      'id': 3,
      'name': 'Premium Headphones',
      'description':
          'Experience crystal clear sound with noise cancellation technology.',
      'image': 'assets/images/668adc4fcd57736f5c718ef0_product-06.png',
      'category': 'Electronics',
      'isVerified': true,
      'reward': 'Ksh 75 Cashback',
    },
  ].obs;

  // Navigate to create new product page
  void _navigateToCreateProduct() async {
    final result = await Get.to(() => const AdminProductEditPage());

    // If we got a result back, add the new product
    if (result != null) {
      // Generate a unique ID (in a real app, this would come from the backend)
      final int newId = _products.isNotEmpty ? _products.last['id'] + 1 : 1;

      // Add ID to the product data
      result['id'] = newId;

      // Add to products list
      _products.add(result);

      Get.snackbar(
        'Success',
        'Product added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate to edit product page
  void _navigateToEditProduct(Map<String, dynamic> product) async {
    final result = await Get.to(() => AdminProductEditPage(product: product));

    // If we got a result back, update the product
    if (result != null) {
      final index = _products.indexWhere((p) => p['id'] == result['id']);
      if (index != -1) {
        _products[index] = result;

        Get.snackbar(
          'Success',
          'Product updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Function to delete a product
  void _deleteProduct(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _products.removeWhere((product) => product['id'] == id);
              Get.back();
              Get.snackbar(
                'Success',
                'Product deleted successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: const Text(
          'Admin Products',
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
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.accentOrange),
            onPressed: _navigateToCreateProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange))
          : Obx(
              () => _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No products available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _navigateToCreateProduct,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _navigateToEditProduct(product),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Product image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[200],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: product['image']
                                              .toString()
                                              .startsWith('/')
                                          ? Image.file(
                                              File(product['image']),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons
                                                      .image_not_supported),
                                            )
                                          : Image.asset(
                                              product['image'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(Icons
                                                      .image_not_supported),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Product info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Category: ${product['category'] ?? 'All'}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Reward: ${product['reward']}',
                                          style: const TextStyle(
                                            color: AppColors.accentOrange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action buttons
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            _navigateToEditProduct(product),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteProduct(product['id']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(
                              duration: 400.ms,
                              delay: Duration(milliseconds: 100 * index),
                            );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentOrange,
        onPressed: _navigateToCreateProduct,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
