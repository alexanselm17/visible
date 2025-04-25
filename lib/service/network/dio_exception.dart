// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  late String message;

  DioExceptions.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = "Oops! Request to the server was cancelled";
        break;
      case DioErrorType.connectionTimeout:
        message = "Oops! Took too long to connect to the server";
        break;
      case DioErrorType.receiveTimeout:
        message = "Oops! The server took too long to respond";
        break;
      case DioErrorType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioErrorType.sendTimeout:
        message = "Oops! Took too long to send request to the server";
        break;
      case DioErrorType.unknown:
        message = "Unexpected error occurred";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String _handleError(int? statusCode, dynamic error) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return error['message'];
      case 403:
        return 'Forbidden';
      case 404:
        return error['message'];
      case 422:
        return jsonEncode(error);
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      default:
        return error['message'];
    }
  }

  @override
  String toString() => message;
}
