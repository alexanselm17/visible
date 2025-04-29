import 'dart:io';
import 'package:dio/dio.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/app_constants.dart';
import 'package:visible/service/network/dio_client.dart';
import 'package:visible/service/network/dio_exception.dart';

class ProductRepository {
  final ApiBaseHelper dioClient = ApiBaseHelper();

  Future<Response?> uploadProductAdvert({
    required File imageFile,
    required String category,
  }) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        "category": category,
      });

      final Response? response = await dioClient.postHTTP(
          "${ApiEndpoints.baseUrl}/upload_product_advert", formData);

      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
      rethrow;
    }
  }

  Future<Response?> getProducts({required String userId}) async {
    try {
      final Response? response = await dioClient.getHTTP(
          "${ApiEndpoints.baseUrl}/campaign/get_product_advert?user_id=$userId");

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
  }) async {
    try {
      final formData = FormData.fromMap({
        "screenshot": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final Response? response = await dioClient.postHTTP(
          "${ApiEndpoints.baseUrl}/upload_screenshot/$productId", formData);

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
