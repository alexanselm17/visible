import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
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
    required String email,
    required String occupation,
    required String password,
    required String cpassword,
    required String location,
    required String gender,
    required String county,
    required String subCounty,
    required String town,
    required String estate,
    required String code,
  }) async {
    try {
      var body = {
        "fullname": fullname,
        "username": username,
        "phone": phone,
        "email": email,
        "password": password,
        "occupation": occupation,
        "location": location,
        "password_confirmation": cpassword,
        "county": county,
        "sub_county": subCounty,
        "town": town,
        "estate": estate,
        "gender": gender,
        "code": code,
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
        'app_version': '1.0.0'
      };
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
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      var body = {
        "email": email,
        "username": username,
        "phone": phone,
        "password": password,
        "password_confirmation": passwordConfirmation
      };

      final Response? response = await dioClient.noTokenPut(
        '${ApiEndpoints.baseUrl}/user/reset_password',
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

  Future updatefcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final Response? response = await dioClient.postHTTP(
        '${ApiEndpoints.baseUrl}/auth/fcm-token',
        {
          'fcm_token': fcmToken,
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

  Future getUserDashboard({
    required String userId,
  }) async {
    try {
      final Response? response = await dioClient.getHTTP(
        '${ApiEndpoints.baseUrl}/campaign/dashboard/$userId',
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future getAdminDashboard({
    required String query,
  }) async {
    try {
      final Response? response = await dioClient.getHTTP(
        '${ApiEndpoints.baseUrl}/campaign/admin_dashboard?time_filter=$query',
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future getProfileData({
    required String userId,
    required String fromDate,
    required String toDate,
    required String status,
    required int page,
  }) async {
    try {
      final Response? response = await dioClient.getHTTP(
        '${ApiEndpoints.baseUrl}/campaign/report/timely_response?user_id=$userId&from_date=$fromDate&to_date=$toDate&status=$status',
      );
      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> downloadPayRoll() async {
    try {
      final response = await dioClient.getHTTPDownload(
        "${ApiEndpoints.baseUrl}/campaign/report/excell_payment",
      );

      if (response != null && response.statusCode == 200) {
        // 🔐 Ask for permission
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          CommonUtils.showErrorToast("Storage permission denied");
          return null;
        }

        // 📂 Path to real Downloads folder (works on most Android devices)
        final downloadsDir = Directory("/storage/emulated/0/Download");
        final filePath = "${downloadsDir.path}/payroll.xlsx";
        final file = File(filePath);

        // 💾 Save the file
        await file.writeAsBytes(response.data, flush: true);

        CommonUtils.showToast("Payroll downloaded to Downloads folder.");
        return file;
      } else {
        CommonUtils.showErrorToast(
            response?.statusMessage ?? "Download failed");
      }
    } catch (e) {
      CommonUtils.showErrorToast("Download error: $e");
    }

    return null;
  }

  Future getUserLocation({
    required String search,
  }) async {
    try {
      final Response? response = await dioClient.getHTTP(
        '${ApiEndpoints.baseUrl}/auth/location?name=$search',
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
