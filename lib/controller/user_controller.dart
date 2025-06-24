import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/model/users/user_model.dart';
import 'package:visible/repository/user_repository.dart';
import 'package:visible/shared_preferences/user_pref.dart';

class UsersController extends GetxController {
  final UserRepository userRepository = UserRepository();
  RxList users = <Datum>[].obs;
  RxList searchUser = <Datum>[].obs;
  RxList activeUserPermissions = [].obs;

  var roles = <Map<String, dynamic>>[].obs;
  var selectedRoles = <String, String>{}.obs;

  var isLoading = false.obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var isFetchingMore = false.obs;

  final lastPage = 1.obs;

  Future<void> getAllUsers({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        users.clear();
        currentPage.value = 1;
        hasMoreData.value = true;
      }
      if (currentPage.value == 1) {
        isLoading.value = true;
      }

      if (!hasMoreData.value) return;
      isFetchingMore.value = true;

      var userResponse =
          await userRepository.getAllUsers(page: currentPage.value);
      Logger().i(userResponse!.data);

      if (userResponse.statusCode == 200) {
        String loggedInUserId = await UserPreferences().getUserId();
        final user = UsersModel.fromJson(userResponse.data);
        if (user.users != null && user.users!.data!.isNotEmpty) {
          users.addAll(user.users!.data!.where((newUser) =>
              newUser.id != loggedInUserId &&
              users.every((existingUser) => existingUser.id != newUser.id)));
          users.refresh();
        }

        hasMoreData.value = user.users?.nextPageUrl != null;
        if (hasMoreData.value) {
          currentPage.value++;
        } else {
          hasMoreData.value = false;
        }
      } else {
        hasMoreData.value = false;
        CommonUtils.showErrorToast('Failed to load users: API returned false');
      }
    } catch (e) {
      CommonUtils.showErrorToast('Failed to load users: $e');
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  Future<void> accountActivation(String id) async {
    try {
      isLoading.value = true;
      if (Get.isOverlaysClosed) {
        Get.dialog(
          barrierDismissible: false,
          const Center(child: CircularProgressIndicator()),
        );
      }

      var userResponse = await userRepository.accountActivation(userId: id);
      isLoading.value = false;

      if (userResponse!.statusCode == 200) {
        searchUser.clear();
        await getAllUsers(isRefresh: true);
        Get.back();
        return CommonUtils.showToast(userResponse.data['message']);
      } else {
        return CommonUtils.showToast(userResponse.data['message']);
      }
    } catch (e) {
      CommonUtils.showErrorToast('Failed to activate account: $e');
    } finally {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      isLoading.value = false;
    }
  }

  Future<void> searchUsers({required String query}) async {
    try {
      isLoading.value = true;

      var userResponse = await userRepository.searchUser(
        query: query,
      );
      isLoading.value = false;

      Logger().i(userResponse);

      if (userResponse!.statusCode == 200) {
        if (userResponse.data['status'] == 'not_found') return;
        final res = UsersModel.fromJson(userResponse.data);
        if (res.users != null || res.users!.data!.isEmpty) {
          searchUser.value = res.users!.data!;
        } else {
          return;
        }
      } else {
        return CommonUtils.showErrorToast(userResponse.data['message']);
      }
    } catch (e) {
      CommonUtils.showErrorToast(' $e');
    } finally {}
  }
}
