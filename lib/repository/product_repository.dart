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
    required File imageFile,
    required String campaignId,
    required String name,
    required String description,
  }) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        "description": description,
        "name": name,
      });

      final Response? response = await dioClient.postHTTP(
          "${ApiEndpoints.baseUrl}/campaign/upload_product_advert/$campaignId",
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

  Future<Response?> uploadVideoProductAdvert({
    required File imageFile,
    required String campaignId,
    required String name,
    required String description,
    required File videoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        "video": await MultipartFile.fromFile(
          videoFile.path,
          filename: videoFile.path.split('/').last, // ✅ Fix here
        ),
        "description": description,
        "name": name,
      });

      final response = await dioClient.postHTTP(
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
