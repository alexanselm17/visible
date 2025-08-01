import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/controller/campaign_controller.dart';
import 'package:visible/model/product_model.dart';
import 'package:visible/repository/product_repository.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:visible/shared_preferences/user_pref.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  var campaignProducts = <Map<String, dynamic>>[].obs;
  CampaignController campaignController = Get.put(CampaignController());

  RxBool isLoading = false.obs;
  RxString uploadStatus = ''.obs;
  RxList<Datum> productsList = <Datum>[].obs;
  RxBool isDownloading = false.obs;
  RxBool isUploading = false.obs;

  RxList<Datum> availableProductsList = <Datum>[].obs;
  RxList<Datum> progressProductsList = <Datum>[].obs;
  RxList<Datum> completedProductsList = <Datum>[].obs;

  // Loading states for each filter
  RxBool isLoadingAvailable = false.obs;
  RxBool isLoadingProgress = false.obs;
  RxBool isLoadingCompleted = false.obs;

  Future<void> uploadProductAdvert({
    File? imageFile,
    File? videoFile,
    File? thumbnailFile,
    required String campaignId,
    required String name,
    required String description,
    required List<String> badge,
    required String category,
    required String reward,
    required String capacity,
    required String validUntil,
    required String capitalInvested,
    required String gender,
    required String countyId,
  }) async {
    try {
      isLoading(true);
      uploadStatus('Uploading...');

      final response = await _productRepository.uploadProductAdvert(
        description: description,
        campaignId: campaignId,
        imageFile: imageFile,
        videoFile: videoFile,
        thumbnailFile: thumbnailFile,
        name: name,
        badge: badge,
        category: category,
        reward: reward,
        capacity: capacity,
        validUntil: validUntil,
        capitalInvested: capitalInvested,
        gender: gender,
        countyId: countyId,
      );

      if (response != null && response.statusCode == 200) {
        await campaignController.fetchCampaignProducts(
            campaignId: campaignId, isRefresh: true);

        Get.back();
        return CommonUtils.showToast('Product advert uploaded successfully');
      } else {
        return CommonUtils.showErrorToast(
            response!.data['message'] ?? 'Failed to upload product advert');
      }
    } catch (e) {
      uploadStatus('Upload failed');
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProductAdvert({
    File? imageFile,
    File? videoFile,
    File? thumbnailFile,
    required String productId,
    required String name,
    required String description,
    required List<String> badge,
    required String category,
    required String reward,
    required String capacity,
    required String validUntil,
    required String capitalInvested,
    required String gender,
    required String countyId,
    required String campaignId,
  }) async {
    try {
      isLoading(true);
      uploadStatus('Uploading...');

      final response = await _productRepository.updateProductAdvert(
        description: description,
        productId: productId,
        imageFile: imageFile,
        videoFile: videoFile,
        thumbnailFile: thumbnailFile,
        name: name,
        badge: badge,
        category: category,
        reward: reward,
        capacity: capacity,
        validUntil: validUntil,
        capitalInvested: capitalInvested,
        gender: gender,
        countyId: countyId,
      );

      if (response != null && response.statusCode == 200) {
        await campaignController.fetchCampaignProducts(
            campaignId: campaignId, isRefresh: true);

        Get.back();
        return CommonUtils.showToast('Product advert uploaded successfully');
      }
    } catch (e) {
      uploadStatus('Upload failed');
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchProducts({required String filter}) async {
    try {
      isLoading.value = true;
      final String userId = await UserPreferences().getUserId();

      final response =
          await _productRepository.getProducts(userId: userId, filter: filter);
      isLoading.value = false;
      productsList.clear();
      productsList.refresh();
      Logger().i(response!.data);

      if (response.statusCode == 200) {
        var product = ProductModel.fromJson(response.data);
        productsList.addAll(product.data!.data!);
      }
    } catch (e) {
      Logger().e("Error fetching products: $e");
      CommonUtils.showErrorToast('Failed to load products');
    } finally {}
  }

  Future fetchProductsByFilter({required String filter}) async {
    try {
      // Set appropriate loading state
      _setLoadingState(filter, true);

      final String userId = await UserPreferences().getUserId();

      final response =
          await _productRepository.getProducts(userId: userId, filter: filter);

      Logger().i("$filter products response: ${response!.data}");

      if (response.statusCode == 200) {
        var productModel = ProductModel.fromJson(response.data);

        // Store in appropriate list based on filter
        switch (filter) {
          case 'available':
            availableProductsList.clear();
            availableProductsList.addAll(productModel.data!.data!);
            availableProductsList.refresh();
            break;
          case 'ongoing':
            progressProductsList.clear();
            progressProductsList.addAll(productModel.data!.data!);
            progressProductsList.refresh();
            break;
          case 'completed':
            completedProductsList.clear();
            completedProductsList.addAll(productModel.data!.data!);
            completedProductsList.refresh();
            break;
        }
      }
    } catch (e) {
      Logger().e("Error fetching $filter products: $e");
      CommonUtils.showErrorToast('Failed to load $filter products');
    } finally {
      _setLoadingState(filter, false);
    }
  }

  void _setLoadingState(String filter, bool loading) {
    switch (filter) {
      case 'available':
        isLoadingAvailable.value = loading;
        break;
      case 'progress':
        isLoadingProgress.value = loading;
        break;
      case 'completed':
        isLoadingCompleted.value = loading;
        break;
    }
  }

  // Get loading state for current filter
  RxBool getLoadingState(String filter) {
    switch (filter) {
      case 'available':
        return isLoadingAvailable;
      case 'ongoing':
        return isLoadingProgress;
      case 'completed':
        return isLoadingCompleted;
      default:
        return isLoadingAvailable;
    }
  }

  // Get current list based on filter
  RxList<Datum> getCurrentList(String filter) {
    switch (filter) {
      case 'available':
        return availableProductsList;
      case 'ongoing':
        return progressProductsList;
      case 'completed':
        return completedProductsList;
      default:
        return availableProductsList;
    }
  }

  int get availableCount => availableProductsList.length;
  int get progressCount => progressProductsList.length;
  int get completedCount => completedProductsList.length;

  Future<void> uploadProductScreenShot({
    required File imageFile,
    required String productId,
    required bool isCompleted,
    required bool isOngoing,
  }) async {
    try {
      isUploading.value = true;
      final String userId = await UserPreferences().getUserId();

      final response = await _productRepository.uploadProductScreenShot(
          imageFile: imageFile, productId: productId, userId: userId);
      isUploading.value = false;
      Logger().i(response!.statusCode);

      if (response.statusCode == 200) {
        Logger().i(response.data);
        Get.back();
        if (isCompleted) {
          progressProductsList
              .removeWhere((product) => product.id == productId);
          progressProductsList.refresh();
        }
        if (isOngoing) {
          fetchProductsByFilter(filter: 'ongoing');
          availableProductsList
              .removeWhere((product) => product.id == productId);
          availableProductsList.refresh();
        }

        CommonUtils.showToast(response.data['message']);
      } else {
        CommonUtils.showErrorToast('Failed !, Please try again later .');
      }
    } catch (e) {
      uploadStatus('Upload failed');
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isUploading(false);
    }
  }

  String _getVideoExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.endsWith('.mp4')) return 'mp4';
    if (path.endsWith('.mov')) return 'mov';
    if (path.endsWith('.avi')) return 'avi';
    if (path.endsWith('.mkv')) return 'mkv';
    if (path.endsWith('.webm')) return 'webm';
    if (path.endsWith('.3gp')) return '3gp';

    // Default to mp4 if extension can't be determined
    return 'mp4';
  }

  Future downloadVideo(String videoUrl) async {
    isDownloading.value = true;
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      isDownloading.value = false;
      Get.snackbar(
        'Permission Denied',
        'Storage or photo permission is required to download videos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Show progress indicator for large video files
      var downloadProgress = 0.0.obs;

      final response = await http.get(
        Uri.parse(videoUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();

        // Get video file extension from URL or default to mp4
        String extension = _getVideoExtension(videoUrl);

        final file = File(
            '${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.$extension');

        await file.writeAsBytes(response.bodyBytes);

        // Save video to gallery
        final saved = await GallerySaver.saveVideo(
          file.path,
          albumName: "Downloaded Videos", // Optional: create custom album
        );

        isDownloading.value = false;

        if (saved == true) {
          Get.snackbar(
            'Download Complete',
            'Video saved to your gallery',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        } else {
          throw Exception('GallerySaver returned false.');
        }
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      isDownloading.value = false;
      Get.snackbar(
        'Download Failed',
        'Could not download the video. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Video download error: $e');
    }
  }

  Future downloadImage(String imageUrl) async {
    isDownloading.value = true;
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      isDownloading.value = false;
      Get.snackbar(
        'Permission Denied',
        'Storage or photo permission is required to download images',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
            '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);

        final saved = await GallerySaver.saveImage(file.path);
        isDownloading.value = false;

        if (saved == true) {
          Get.snackbar(
            'Download Complete',
            'Image saved to your gallery',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          throw Exception('GallerySaver returned false.');
        }
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Download Failed',
        'Could not download the image. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.request().isGranted) return true;
      if (await Permission.storage.request().isGranted) return true;
      return false;
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }
    return false;
  }
}
