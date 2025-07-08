import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' as getx;
import 'package:get/route_manager.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/app_constants.dart';

import 'dart:io';

import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/screens/auth/login_page.dart';
import 'package:visible/shared_preferences/user_pref.dart';

class ApiBaseHelper {
  static const String url = ApiEndpoints.baseUrl;
  static bool redirected = false;

  static BaseOptions opts = BaseOptions(
    baseUrl: url,
    followRedirects: true,
    responseType: ResponseType.json,
  );

  static Dio createDio() {
    Dio dio = Dio(opts);

    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return dio;
  }

  static Dio addInterceptors(Dio dio) {
    return dio
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (RequestOptions options, handler) {
            requestInterceptor(options);
            return handler.next(options);
          },
          onError: (DioException e, handler) async {
            Logger().e(e);
            if (e.response?.statusCode == 400) {
              final errorMessage = e.response?.data['message'] ?? 'Bad request';
              CommonUtils.showErrorToast(errorMessage);
            }
            if (e.response?.statusCode == 401 ||
                e.response?.statusCode == 500 && redirected != true) {
              getx.Get.put(AuthenticationController()).errorLogOut();
              return getx.Get.offAll(() => const LoginPage());
            }
            return handler.next(e);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
        ),
      );
  }

  static dynamic requestInterceptor(RequestOptions options) async {
    String token = await UserPreferences().getToken();
    options.headers.addAll({
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    });
    return options;
  }

  static final dio = createDio();
  static final baseAPI = addInterceptors(dio);

  getHTTP(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      Response response = await baseAPI.get(
        url,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      print(e);
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }

  getHTTPDownload(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      Response response = await baseAPI.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      return response;
    } on DioException catch (e) {
      print(e);
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }

  getHTTPBody(String url, dynamic data) async {
    try {
      Response response = await baseAPI.get(
        url,
        data: data,
        options: Options(
          method: 'GET',
        ),
      );
      return response;
    } on DioException catch (e) {
      print(e);
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }

  postHTTP(String url, dynamic data) async {
    try {
      Response response = await baseAPI.post(url, data: data);
      return response;
    } on DioException catch (e) {
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }

  putHTTP(String url, dynamic data) async {
    try {
      Response response = await baseAPI.put(url, data: data);
      return response;
    } on DioException catch (e) {
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }

  deleteHTTP(String url) async {
    try {
      Response response = await baseAPI.delete(url);
      return response;
    } on DioException catch (e) {
      print('Error in DELETE: $e');
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }

  Future<Response> queryHTTP(String url, Map<String, dynamic> params) async {
    try {
      final response = await dio.get(url, queryParameters: params);
      return response;
    } catch (e) {
      if (e is DioException) {
        return Response(
          requestOptions: e.requestOptions,
          data: e.response?.data,
          statusCode: e.response?.statusCode,
          statusMessage: e.response?.statusMessage,
        );
      }
      rethrow;
    }
  }

  Future<Response?> noTokenPost(String url, dynamic data) async {
    try {
      Dio dioWithoutToken = createDio();
      dioWithoutToken.options.headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      Response response = await dioWithoutToken.post(url, data: data);
      return response;
    } on DioException catch (e) {
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }

  Future<Response?> noTokenPut(String url, dynamic data) async {
    try {
      Dio dioWithoutToken = createDio();
      dioWithoutToken.options.headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      Response response = await dioWithoutToken.put(url, data: data);
      return response;
    } on DioException catch (e) {
      return Response(
        requestOptions: e.requestOptions,
        data: e.response?.data,
        statusCode: e.response?.statusCode,
        statusMessage: e.response?.statusMessage,
      );
    }
  }
}
