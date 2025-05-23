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

  Future<Response?> transferEmployee({
    required String userId,
    required String petrolStationId,
  }) async {
    try {
      final response = await dioClient.putHTTP(
        "${ApiEndpoints.usersEndpoint}/transfer_user",
        {
          "user_id": userId,
          "to_petrol_id": petrolStationId,
        },
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<Response?> unassignRole({
    required String userId,
  }) async {
    try {
      final response = await dioClient.putHTTP(
        ApiEndpoints.unassignRoleEndpoint,
        {"user_id": userId},
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<Response?> assignPermission({
    required String userId,
    required List permissions,
  }) async {
    var body = {"user_id": userId, "permissions": permissions};
    try {
      final response = await dioClient.postHTTP(
          "${ApiEndpoints.usersEndpoint}/assign_permissions", body);
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future<Response?> assignRole({
    required String userId,
    required String roleId,
  }) async {
    try {
      final response = await dioClient.putHTTP(
        '${ApiEndpoints.baseUrl}/user/assign_role',
        {
          "user_id": userId,
          "role_id": roleId,
        },
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

  Future<Response?> fetchRoles() async {
    try {
      final response =
          await dioClient.getHTTP("${ApiEndpoints.baseUrl}/user/get_Roles");
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }
}
