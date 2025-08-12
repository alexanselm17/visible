import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/roles_constants.dart';
import 'package:visible/model/auth/location_search.dart';
import 'package:visible/model/auth/sign_in_model.dart';
import 'package:visible/model/users/referal_user.dart';
import 'package:visible/model/users/report.dart' as report;
import 'package:visible/model/users/user_model.dart';
import 'package:visible/repository/auth_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visible/screens/auth/login_page.dart';
import 'package:visible/service/network/dio_exception.dart';
import 'package:visible/service/notification/pushNotification.dart';
import 'package:visible/shared_preferences/user_pref.dart';

import 'package:visible/screens/user/main_screen.dart' as user;
import 'package:visible/screens/admin/main_screen.dart' as admin;
import 'package:visible/model/users/user_model.dart' as ref;

class AuthenticationController extends GetxController {
  final AuthRepository authRepository = AuthRepository();
  final fullNameController = TextEditingController();
  final userNameController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();
  final emailController = TextEditingController();
  final cardNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final usernameController = TextEditingController();
  final loginPasswordController = TextEditingController();

  Rx<Data> currentUser = Data().obs;

  final isLoading = false.obs;

  final isLoggingIn = false.obs;
  final passwordVisible = false.obs;

  final RxBool isPasswordReset = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final signInModel = await UserPreferences().getSignInModel();
      final token = await UserPreferences().getToken();

      if (signInModel != null && signInModel.data != null && token.isNotEmpty) {
        currentUser.value = signInModel.data!;
        currentUser.refresh();
        refresh();
        Logger().i("User data loaded from preferences");
      } else {
        currentUser.value = Data();
        await UserPreferences().logout();
        Logger().w("No valid stored user data found - cleared preferences");
      }
    } catch (e) {
      Logger().e("Error loading user data: $e");
      currentUser.value = Data();
      await UserPreferences().logout();
    }
  }

  Future<void> handleSignUp({
    required String fullname,
    required String username,
    required String phone,
    required String password,
    required String cpassword,
    required String email,
    required String occupation,
    required String gender,
    required String county,
    required String subCounty,
    required String code,
    required String town,
    required String estate,
  }) async {
    try {
      isLoading.value = true;

      // Get and store FCM token
      final fcmToken = await PushNotification().getDeviceToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', fcmToken);

      final formattedPhone = "+254${phone.replaceAll(' ', '')}";

      final res = await authRepository.userSignUp(
        fullname: fullname,
        username: username,
        phone: formattedPhone,
        password: password,
        cpassword: cpassword,
        email: email,
        occupation: occupation,
        gender: gender,
        county: county,
        town: town,
        estate: estate,
        subCounty: subCounty,
        code: code,
        fcmToken: fcmToken,
      );
      Logger().i(res!.data);
      Logger().i(res.statusCode);

      if ((res.statusCode == 200 || res.statusCode == 201)) {
        isLoading.value = false;
        Get.offAll(const LoginPage());
        CommonUtils.showToast(
            res.data['message'] ?? 'Sign-up successful! Please log in.');
      } else {
        isLoading.value = false;
        final errorMessage =
            res.data?['message'] ?? 'Sign-up failed. Please try again.';
        CommonUtils.showErrorToast(errorMessage);
      }
    } catch (e) {
      isLoading.value = false;

      print('Sign-up error: $e');

      CommonUtils.showErrorToast(
          "Sign-up failed. Please check your connection and try again.");
    }
  }

  Future<void> handleSignIn({
    required String userName,
    required String password,
  }) async {
    try {
      isLoggingIn.value = true;

      final userSignInResponse = await authRepository.userSign(
        username: userName,
        password: password,
      );

      isLoggingIn.value = false;

      Logger().i(userSignInResponse!.data);

      if (userSignInResponse.statusCode == 200) {
        final data = SignInModel.fromJson(userSignInResponse.data);
        await UserPreferences().storeSignInModel(data);
        await UserPreferences().storeToken(data.token!);
        await UserPreferences().storeUserId(data.data!.id!);
        await UserPreferences().storeRoleId(data.data!.role!.id!);
        await UserPreferences().storeUserSlug(data.data!.role!.slug!);

        final fcmToken = await PushNotification().getDeviceToken();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', fcmToken);
        await updateFcmToken(fcmToken);

        isLoggingIn.value = false;
        Get.offUntil(
          MaterialPageRoute(
              builder: (_) => data.data!.role!.slug == RoleConstants.ADMIN
                  ? const admin.MainScreen()
                  : const user.MainScreen()),
          (route) => false,
        );
      } else {
        CommonUtils.showErrorToast(userSignInResponse.data['message']);
        usernameController.text = "";
        passwordController.text = "";
      }
      isLoggingIn.value = false;
    } catch (e) {
      usernameController.text = "";
      passwordController.text = "";
      isLoggingIn.value = false;
      CommonUtils.showErrorToast(e.toString());
    }
  }

  Future logOut() async {
    try {
      String id = await UserPreferences().getUserId();

      final response = await authRepository.logoutUserApi(userId: id);
      if (response!.statusCode == 200) {
        await UserPreferences().logout();
        CommonUtils.showToast('Logged out sucessfully');
        Get.offAll(const LoginPage());
      }
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future errorLogOut() async {
    try {
      String id = await UserPreferences().getUserId();

      final response = await authRepository.logoutUserApi(userId: id);
      if (response!.statusCode == 200) {
        CommonUtils.showToast('Logged out sucessfully');
        Get.offAll(const LoginPage());
      }
    } on DioException catch (e) {
      final errorMessage = DioExceptions.fromDioError(e).toString();
      throw errorMessage;
    }
  }

  Future updateFcmToken(String token) async {
    try {
      String id = await UserPreferences().getUserId();
      final response =
          await authRepository.updatefcmToken(userId: id, fcmToken: token);
      if (response!.statusCode == 200) {
        Logger().i("FCM Token updated successfully");
      } else {
        CommonUtils.showErrorToast(response.data['message']);
      }
    } catch (e) {
      CommonUtils.showErrorToast("Failed to update FCM Token: $e");
    }
  }

  Future<void> resetPassword({
    required bool isLoggedIn,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoggingIn.value = true;
      final formattedPhone = phone
              .replaceAll(RegExp(r'\s+'), '')
              .startsWith('+254')
          ? phone.replaceAll(RegExp(r'\s+'), '')
          : '+254${phone.replaceAll(RegExp(r'\s+'), '').replaceFirst(RegExp(r'^0'), '')}';

      final userSignInResponse = await authRepository.resetPassword(
        email: email,
        username: username,
        password: password,
        phone: formattedPhone,
        passwordConfirmation: passwordConfirmation,
      );

      isLoggingIn.value = false;
      isPasswordReset.value = false;

      Logger().f(userSignInResponse!.data);

      if (userSignInResponse.data['ok'] == true) {
        isPasswordReset.value = false;

        isPasswordReset.value = true;
        CommonUtils.showToast(userSignInResponse.data['message']);
        isLoggedIn ? null : Get.off(const LoginPage());
      } else {
        isPasswordReset.value = false;
        CommonUtils.showErrorToast(userSignInResponse.data['message']);
      }
      isLoggingIn.value = false;
      isPasswordReset.value = false;
    } catch (e) {
      isPasswordReset.value = false;
      usernameController.text = "";
      passwordController.text = "";
      isLoggingIn.value = false;
      CommonUtils.showErrorToast(e.toString());
    }
  }

  Future getUserDashboard() async {
    // try {
    String id = await UserPreferences().getUserId();
    final response = await authRepository.getUserDashboard(userId: id);
    if (response!.statusCode == 200) {
      Logger().i("User dashboard data fetched successfully");
      return response.data;
    } else {
      CommonUtils.showErrorToast(response.data['message']);
    }
    // } catch (e) {
    //   CommonUtils.showErrorToast("Failed to fetch user dashboard: $e");
    // }
    // return null;
  }

  Future getAdminDashboard({required String query}) async {
    try {
      final response = await authRepository.getAdminDashboard(query: query);
      if (response!.statusCode == 200) {
        Logger().i("User dashboard data fetched successfully");
        Logger().i(response);
        return response.data;
      } else {
        CommonUtils.showErrorToast(response.data['message']);
      }
    } catch (e) {
      CommonUtils.showErrorToast("Failed to fetch user dashboard: $e");
    }
    return null;
  }

  Future<void> downloadPayRoll() async {
    try {
      final file = await authRepository.downloadPayRoll();

      if (file != null) {
        CommonUtils.showToast("Payroll saved to Downloads: ${file.path}");
      } else {
        CommonUtils.showErrorToast("Payroll not downloaded.");
      }
    } catch (e) {
      CommonUtils.showErrorToast("Failed to download payroll: $e");
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
      final response = await authRepository.getProfileData(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
        status: status,
        page: page,
      );
      Logger().i("Profile data fetched successfully: ${response!.data}");
      if (response.statusCode == 200) {
        final userReport = report.UserReport.fromJson(response.data);
        return userReport.data!.data;
      } else {}
    } catch (e) {}
  }

  Future getUserLocation({
    required String search,
  }) async {
    try {
      final response = await authRepository.getUserLocation(
        search: search,
      );
      if (response.statusCode == 200) {
        final userReport = LocationSearch.fromJson(response.data);
        return userReport.data;
      } else {}
    } catch (e) {}
  }

  RxList<ref.Datum> users = <ref.Datum>[].obs;
  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var hasMoreData = true.obs;
  var isFetchingMore = false.obs;

  Future<void> getUserReferrals({
    required String userId,
    bool isRefresh = false,
  }) async {
    try {
      if (isRefresh) {
        users.clear();
        currentPage.value = 1;
        lastPage.value = 1;
        hasMoreData.value = true;
        isFetchingMore.value = false;
      }

      if (!hasMoreData.value) return;

      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isFetchingMore.value = true;
      }

      final userResponse = await authRepository.getUserRefarals(
        userId: userId,
        page: currentPage.value,
      );
      Logger().i("User referrals fetched: ${userResponse!.data}");

      if (userResponse?.statusCode != 200) {
        CommonUtils.showErrorToast(
          'Failed to load users: API returned ${userResponse?.statusCode}',
        );
        return;
      }

      final referralData = RefaralUserModel.fromJson(userResponse!.data);

      if (referralData.referrals?.data != null) {
        final List<ref.Datum> newUsers = referralData.referrals!.data!
            .map((e) => ref.Datum.fromJson(e.toJson()))
            .toList();

        // Avoid duplicates
        final existingIds = users.map((user) => user.id).toSet();
        final uniqueNewUsers =
            newUsers.where((user) => !existingIds.contains(user.id)).toList();

        users.addAll(uniqueNewUsers);
        users.refresh();
      }

      lastPage.value = referralData.referrals?.lastPage ?? 1;
      hasMoreData.value = (referralData.referrals!.nextPageUrl != null) &&
          (currentPage.value < lastPage.value);

      if (hasMoreData.value) {
        currentPage.value++;
      }
    } catch (e, stackTrace) {
      CommonUtils.showErrorToast('Failed to load users: $e');
      Logger().e("Error fetching referrals: $e");
      Logger().e("Stack trace: $stackTrace");
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }
}
