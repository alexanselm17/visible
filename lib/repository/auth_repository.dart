import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/app_constants.dart';
import 'package:visible/service/network/dio_client.dart';
import 'package:visible/service/network/dio_exception.dart';

class AuthRepository {
  final ApiBaseHelper dioClient = ApiBaseHelper();

  Future<Response?> userSignUp({
    required String fullname,
    required String username,
    required String phone,
    required int nationalId,
    required String email,
    required String occupation,
    required String password,
    required String cpassword,
    required String location,
    required String gender,
  }) async {
    try {
      var body = {
        "fullname": fullname,
        "username": username,
        "phone": phone,
        "email": email,
        "national_id": nationalId,
        "password": password,
        "occupation": occupation,
        "location": location,
        "password_confirmation": cpassword,
        "gender": gender
      };
      Logger().d(body);
      final Response? response =
          await dioClient.postHTTP(ApiEndpoints.signUpEndpoint, body);

      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
      rethrow;
    }
  }

  Future<Response?> userSign({
    required String username,
    required String password,
  }) async {
    try {
      var body = {
        'username': username,
        'password': password,
        'app_version': '1.0.4'
      };
      print(ApiEndpoints.signInEndpoint);
      final Response? response =
          await dioClient.noTokenPost(ApiEndpoints.signInEndpoint, body);
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> resetPassword({
    required String username,
    required String phone,
    required String nationalId,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      var body = {
        "username": username,
        "phone": phone,
        "national_id": nationalId,
        "password": password,
        "password_confirmation": passwordConfirmation
      };
      print(body);
      final Response? response = await dioClient.noTokenPut(
          '${ApiEndpoints.baseUrl}/user/reset_password', body);
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> logoutUserApi({
    required String userId,
  }) async {
    try {
      final Response? response = await dioClient.putHTTP(
        ApiEndpoints.logoutEndpoint,
        {
          'user_id': userId,
        },
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> getUserHomeDetails({
    required String roleId,
    required String userId,
    required String companyId,
    required String visibleStationId,
  }) async {
    try {
      print(
          "${ApiEndpoints.baseUrl}/dashboard/$userId/$roleId/$companyId?visible_id=$visibleStationId");
      final Response? response = await dioClient.getHTTP(
          "${ApiEndpoints.baseUrl}/dashboard/$userId/$roleId/$companyId?visible_id=$visibleStationId");
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response?> createvisibleStation({
    required String name,
    required String type,
    required String companyId,
  }) async {
    try {
      var body = {
        'name': name,
        'type': type,
      };
      final Response? response = await dioClient.postHTTP(
        '${ApiEndpoints.baseUrl}/setup/company/visible_station/$companyId',
        body,
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }
}
