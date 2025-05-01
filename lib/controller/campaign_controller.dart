import 'package:get/get.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/model/campaign/campaign_model.dart';
import 'package:visible/repository/campaign_repository.dart';

class CampaignController extends GetxController {
  final CampaignRepository _campaignRepository = CampaignRepository();

  // Observables
  final isLoading = false.obs;

  RxList<Datum> campaigns = <Datum>[].obs;

  @override
  void onInit() {
    fetchCampaigns();
    super.onInit();
  }

  Future<void> fetchCampaigns() async {
    try {
      isLoading.value = true;
      final response = await _campaignRepository.fetchCampaigns();

      if (response?.statusCode == 200) {
        var data = CampaignModel.fromJson(response!.data);
        campaigns.value = data.data!.data!;
      } else {
        CommonUtils.showErrorToast("Failed to fetch campaigns.");
      }
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCampaign({
    required String name,
    required int capitalInvested,
    required String validUntil,
    required int reward,
    required int capacity,
  }) async {
    try {
      isLoading.value = true;

      final response = await _campaignRepository.createCampaign(
        name: name,
        capitalInvested: capitalInvested,
        validUntil: validUntil,
        reward: reward,
        capacity: capacity,
      );

      if (response?.statusCode == 201 || response?.statusCode == 200) {
        CommonUtils.showToast("Campaign created successfully!");
        await fetchCampaigns();
      } else {
        CommonUtils.showErrorToast("Failed to create campaign.");
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
        CommonUtils.showToast("Campaign updated successfully!");
        await fetchCampaigns();
      } else {
        CommonUtils.showErrorToast("Failed to update campaign.");
      }
    } catch (e) {
      CommonUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
