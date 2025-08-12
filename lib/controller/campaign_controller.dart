import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/model/campaign/campaign_model.dart' as campaign;
import 'package:visible/model/campaign/campaign_product.dart';
import 'package:visible/model/campaign/fraud.dart';
import 'package:visible/repository/campaign_repository.dart';

class CampaignController extends GetxController {
  final CampaignRepository _campaignRepository = CampaignRepository();

  // Observables
  final isLoading = false.obs;

  RxList<campaign.Datum> campaigns = <campaign.Datum>[].obs;
  List<Datum> productsInCampaign = <Datum>[].obs;
  final Rx<FraudUserModel?> fraudUserModel = Rx<FraudUserModel?>(null);

  var currentPage = 1.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;
  var hasMore = true.obs;

  @override
  void onInit() {
    fetchCampaigns();
    super.onInit();
  }

  Future<void> fetchCampaigns() async {
    try {
      isLoading.value = true;
      final response = await _campaignRepository.fetchCampaigns();
      Logger().i(response!.data);

      if (response.statusCode == 200) {
        var data = campaign.CampaignModel.fromJson(response.data);
        campaigns.value = data.data!;
      } else {
        CommonUtils.showErrorToast("Failed to fetch campaigns.");
      }
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCampaignProducts(
      {bool isRefresh = false, required String campaignId}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMore.value = true;
        productsInCampaign.clear();
      }
      isLoading.value = true;

      final response = await _campaignRepository.fetchProductsInCampaign(
          campaignId: campaignId);
      isLoading.value = false;

      if (response!.statusCode == 200) {
        final model = CampaignProductModel.fromJson(response.data);

        if (isRefresh) {
          productsInCampaign = model.data?.data ?? [];
        } else {
          productsInCampaign.addAll(model.data?.data ?? []);
        }

        // Pagination logic
        final pagination = model.pagination;
        if (pagination != null) {
          hasMore.value = pagination.currentPage! < pagination.lastPage!;
          if (!isRefresh) currentPage.value++;
        }
      } else {}
    } finally {
      isLoadingMore.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> createCampaign({
    required String name,
  }) async {
    try {
      isLoading.value = true;

      final response = await _campaignRepository.createCampaign(
        name: name,
      );

      if (response?.statusCode == 201 || response?.statusCode == 200) {
        await fetchCampaigns();
        Get.back();
        return CommonUtils.showToast("Campaign created successfully!");
      } else {
        CommonUtils.showErrorToast(
            response?.data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCampaign({
    required String campaignId,
    required String name,
    required int capitalInvested,
    required String validUntil,
    required int reward,
    required int capacity,
  }) async {
    try {
      isLoading.value = true;

      final response = await _campaignRepository.updateCampaign(
        campaignId: campaignId,
        name: name,
        capitalInvested: capitalInvested,
        validUntil: validUntil,
        reward: reward,
        capacity: capacity,
      );

      if (response?.statusCode == 200) {
        await fetchCampaigns();
        Get.back();
        Get.back();
        return CommonUtils.showToast("Campaign updated successfully!");
      } else {
        CommonUtils.showErrorToast(response!.data["message"]);
      }
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFraudInCampaign({
    required String campaignId,
  }) async {
    try {
      isLoading.value = true;
      final response = await _campaignRepository.fetchFraudInCampaign(
        campaignId: campaignId,
      );

      if (response!.statusCode == 200) {
        fraudUserModel.value = FraudUserModel.fromJson(response.data);
        Logger().i(response.data);
      } else {
        CommonUtils.showErrorToast("Failed to fetch fraud data.");
      }
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
