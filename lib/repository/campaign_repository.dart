import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/app_constants.dart';
import 'package:visible/service/network/dio_client.dart';
import 'package:visible/service/network/dio_exception.dart';

class CampaignRepository {
  final ApiBaseHelper dioClient = ApiBaseHelper();

  Future<Response?> fetchCampaigns() async {
    try {
      final Response? response =
          await dioClient.getHTTP('${ApiEndpoints.baseUrl}/campaign');

      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
      rethrow;
    }
  }

  Future<Response?> createCampaign({
    required String name,
    required int capitalInvested,
    required String validUntil,
    required int reward,
    required int capacity,
  }) async {
    try {
      var body = {
        "name": name,
        "capital_invested": capitalInvested,
        "valid_until": validUntil,
        "reward": reward,
        "capacity": capacity,
      };

      Logger().d(body);

      final Response? response =
          await dioClient.postHTTP('${ApiEndpoints.baseUrl}/campaign', body);

      return response;
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
      rethrow;
    }
  }

  Future<Response?> updateCampaign({
    required String campaignId,
    required String name,
    required int capitalInvested,
    required String validUntil,
    required int reward,
    required int capacity,
  }) async {
    try {
      var body = {
        "name": name,
        "capital_invested": capitalInvested,
        "valid_until": validUntil,
        "reward": reward,
        "capacity": capacity,
      };

      Logger().d(body);

      final Response? response = await dioClient.putHTTP(
        "${ApiEndpoints.baseUrl}/campaign/$campaignId",
        body,
      );

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
