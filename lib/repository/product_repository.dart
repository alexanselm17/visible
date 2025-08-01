import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/app_constants.dart';
import 'package:visible/service/network/dio_client.dart';
import 'package:visible/service/network/dio_exception.dart';

class ProductRepository {
  final ApiBaseHelper dioClient = ApiBaseHelper();

  Future<Response?> uploadProductAdvert({
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
      final formData = FormData();

      // Media handling
      if (videoFile != null) {
        formData.files.add(MapEntry(
          "video",
          await MultipartFile.fromFile(videoFile.path,
              filename: videoFile.path.split('/').last),
        ));

        if (thumbnailFile != null) {
          formData.files.add(MapEntry(
            "thumbnail",
            await MultipartFile.fromFile(thumbnailFile.path,
                filename: thumbnailFile.path.split('/').last),
          ));
        }
      } else if (imageFile != null) {
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        ));
      }

      final targetAudienceJson = {
        "gender": gender,
        "county_id": countyId,
      };

      final targetAudience = targetAudienceJson.values.every((v) => v == "")
          ? null
          : targetAudienceJson;

      formData.fields.addAll([
        MapEntry("description", description),
        MapEntry("name", name),
        MapEntry("category", category),
        MapEntry("reward", reward),
        MapEntry("capacity", capacity),
        MapEntry("valid_until", validUntil),
        const MapEntry("selling_price", '0'),
        MapEntry("capital_invested", capitalInvested),
        MapEntry("target_audience", jsonEncode(targetAudience)),
        for (var b in badge) MapEntry("badge[]", b),
      ]);

      final Response? response = await dioClient.postHTTP(
        "${ApiEndpoints.baseUrl}/campaign/upload_product_advert/$campaignId",
        formData,
      );

      Logger().i(response!.data);
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
      rethrow;
    }
  }

  Future<Response?> updateProductAdvert({
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
  }) async {
    try {
      final formData = FormData();

      // Media handling
      if (videoFile != null) {
        formData.files.add(MapEntry(
          "video",
          await MultipartFile.fromFile(videoFile.path,
              filename: videoFile.path.split('/').last),
        ));

        if (thumbnailFile != null) {
          formData.files.add(MapEntry(
            "thumbnail",
            await MultipartFile.fromFile(thumbnailFile.path,
                filename: thumbnailFile.path.split('/').last),
          ));
        }
      } else if (imageFile != null) {
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(imageFile.path,
              filename: imageFile.path.split('/').last),
        ));
      }

      final targetAudienceJson = {
        "gender": gender,
        "county_id": countyId,
      };

      // Add all fields
      formData.fields.addAll([
        MapEntry("description", description),
        MapEntry("name", name),
        MapEntry("category", category),
        MapEntry("reward", reward),
        MapEntry("capacity", capacity),
        MapEntry("valid_until", validUntil),
        const MapEntry("selling_price", '0'),
        MapEntry("capital_invested", capitalInvested),
        MapEntry("target_audience", jsonEncode(targetAudienceJson)),
        for (var b in badge) MapEntry("badge[]", b),
      ]);

      final Response? response = await dioClient.putHTTP(
        "${ApiEndpoints.baseUrl}/campaign/advert/$productId",
        formData,
      );

      Logger().i(response!.data);
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
      rethrow;
    }
  }

  Future<Response?> getProducts(
      {required String userId, required String filter}) async {
    try {
      final Response? response = await dioClient.getHTTP(
          "${ApiEndpoints.baseUrl}/campaign/get_product_advert?user_id=$userId&status=$filter");

      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> uploadProductScreenShot({
    required File imageFile,
    required String productId,
    required String userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        "screenshot": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        "user_id": userId,
      });

      final Response? response = await dioClient.postHTTP(
          "${ApiEndpoints.baseUrl}/campaign/upload_screenshot/$productId",
          formData);
      Logger().i(response!.data);

      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
      rethrow;
    }
  }
}
