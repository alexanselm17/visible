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

  Future<void> uploadProductAdvert({
    required File imageFile,
    required String campaignId,
    required String name,
  }) async {
    try {
      isLoading(true);
      uploadStatus('Uploading...');

      final response = await _productRepository.uploadProductAdvert(
        campaignId: campaignId,
        imageFile: imageFile,
        name: name,
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

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final String userId = await UserPreferences().getUserId();

      final response = await _productRepository.getProducts(userId: userId);
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

  Future<void> uploadProductScreenShot({
    required File imageFile,
    required String productId,
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
