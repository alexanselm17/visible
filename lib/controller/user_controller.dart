import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/model/users/notification.dart' as notif;
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

  // Observable lists and variables
  final RxList<notif.Notification> notifications = <notif.Notification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt totalNotifications = 0.obs;
  final RxBool hasMore = false.obs;
  final int perPage = 20;

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        notifications.clear();
      }

      isLoading.value = true;
      hasError.value = false;

      final String userId = await UserPreferences().getUserId();

      final response = await userRepository.getUserNotifications(
        userId: userId,
        page: currentPage.value,
      );

      if (response.statusCode == 200) {
        final notificationData =
            notif.UserNotifications.fromJson(response.data);

        final newNotifications = notificationData.notifications ?? [];

        if (refresh || currentPage.value == 1) {
          notifications.value = newNotifications;
        } else {
          notifications.addAll(newNotifications);
        }

        // ✅ Pagination
        final pagination = notificationData.pagination;
        currentPage.value = pagination?.currentPage ?? 1;
        lastPage.value = pagination?.lastPage ?? 1;
        totalNotifications.value = pagination?.total ?? 0;
        hasMore.value = pagination?.hasMore ?? false;

        // ✅ Unread count
        unreadCount.value = notificationData.unreadCount ?? 0;
      } else {
        hasError.value = true;
        errorMessage.value =
            "Failed to load notifications: ${response.statusMessage}";
        throw Exception(
            "Failed to load notifications: ${response.statusMessage}");
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
  }

  Future<void> loadMoreNotifications() async {
    if (hasMore.value && !isLoading.value) {
      currentPage.value += 1;
      await fetchNotifications();
    }
  }

  void markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead!) {
      final updatedNotification = notif.Notification(
        id: notifications[index].id,
        userId: notifications[index].userId,
        title: notifications[index].title,
        message: notifications[index].message,
        type: notifications[index].type,
        isRead: true,
        createdAt: notifications[index].createdAt,
        data: notifications[index].data,
      );

      notifications[index] = updatedNotification;
      unreadCount.value = notifications.where((n) => !n.isRead!).length;
      final String userId = await UserPreferences().getUserId();

      userRepository.markNotificationAsRead(
          notificationId: notificationId, userId: userId);
    }
  }

  final isDownloading = false.obs;
  final downloadError = ''.obs;

  Future<void> downloadCampaignReport({
    required String fromDate,
    required String toDate,
  }) async {
    isDownloading.value = true;
    downloadError.value = '';

    try {
      final String userId = await UserPreferences().getUserId();
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        downloadError.value = 'Storage permission denied.';
        isDownloading.value = false;
        return;
      }

      final response = await userRepository.downloadReport(
        fromDate: fromDate,
        toDate: toDate,
        userId: userId,
      );

      if (response != null && response.statusCode == 200) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        final filePath =
            '${downloadsDir.path}/campaign_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(response.data, flush: true);
        isDownloading.value = false;

        CommonUtils.showToast(
            'Download Complete ,File saved to Downloads folder.');
      } else {
        downloadError.value = 'Failed to download PDF.';
      }
    } catch (e) {
      downloadError.value = e.toString();
      print('Download error: $e');
      isDownloading.value = false;
    } finally {
      isDownloading.value = false;
    }
  }
}
