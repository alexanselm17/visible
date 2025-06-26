import 'package:dio/dio.dart';
import 'package:visible/constants/app_constants.dart';
import 'package:visible/service/network/dio_client.dart';
import 'package:visible/service/network/dio_exception.dart';

class UserRepository {
  final ApiBaseHelper dioClient = ApiBaseHelper();

  Future<Response?> getAllUsers({required int page}) async {
    try {
      final Response? response =
          await dioClient.getHTTP('${ApiEndpoints.usersEndpoint}?page=$page');
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> getPermissions({
    required String userId,
  }) async {
    try {
      final Response? response = await dioClient
          .getHTTP('${ApiEndpoints.usersEndpoint}/user_permissions/$userId');
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> accountActivation({
    required String userId,
  }) async {
    try {
      final response = await dioClient.putHTTP(
        ApiEndpoints.usersActivationEndpoint,
        {"user_id": userId},
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<Response?> searchUser({
    required String query,
  }) async {
    try {
      final response = await dioClient
          .getHTTP("${ApiEndpoints.baseUrl}/user/search?query=$query");
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<Response> getUserNotifications({
    required String userId,
    int? perPage,
  }) async {
    try {
      final response = await dioClient.getHTTP(
        "${ApiEndpoints.baseUrl}/notifications/user",
        queryParameters: {
          'user_id': userId,
          if (perPage != null) 'per_page': perPage,
        },
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw Exception(errorMessage);
    }
  }

  Future<Response> markNotificationAsRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final response = await dioClient.postHTTP(
        "${ApiEndpoints.baseUrl}/notifications/mark-read",
        {
          'notification_id': notificationId,
          'user_id': userId,
        },
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw Exception(errorMessage);
    }
  }
}
