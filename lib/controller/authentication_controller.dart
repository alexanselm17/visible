import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/constants/roles_constants.dart';
import 'package:visible/model/auth/sign_in_model.dart';
import 'package:visible/repository/auth_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:visible/screens/auth/login_page.dart';
import 'package:visible/service/network/dio_exception.dart';
import 'package:visible/service/notification/pushNotification.dart';
import 'package:visible/shared_preferences/user_pref.dart';

import 'package:visible/screens/user/main_screen.dart' as user;
import 'package:visible/screens/admin/main_screen.dart' as admin;

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

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final signInModel = await UserPreferences().getSignInModel();
      if (signInModel != null && signInModel.data != null) {
        currentUser.value = signInModel.data!;
        currentUser.refresh();
        Logger().i("User data loaded from preferences");
      } else {
        Logger().w("No stored user data found");
      }
    } catch (e) {
      Logger().e("Error loading user data: $e");
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
    required String location,
    required String gender,
  }) async {
    try {
      isLoading.value = true;

      final random = Random();
      final generatedNationalId = 10000000 + random.nextInt(90000000);

      final res = await authRepository.userSignUp(
          fullname: fullname,
          username: username,
          phone: "+254${phone.replaceAll(' ', '')}",
          nationalId: generatedNationalId,
          password: password,
          cpassword: cpassword,
          email: email,
          occupation: occupation,
          location: location,
          gender: gender);

      isLoading.value = false;

      if (res!.statusCode == 200) {
        Get.offUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );

        isLoading.value = true;
      } else {
        return CommonUtils.showErrorToast(res.data['message']);
      }
    } catch (e) {
      isLoading.value = false;
      CommonUtils.showErrorToast("Sign-up failed. Please try again.");
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
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
    required String username,
    required String phone,
    required String nationalId,
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
        username: username,
        password: password,
        phone: formattedPhone,
        nationalId: nationalId,
        passwordConfirmation: passwordConfirmation,
      );

      isLoggingIn.value = false;

      Logger().f(userSignInResponse!.data);

      if (userSignInResponse.data['ok'] == true) {
        CommonUtils.showToast(userSignInResponse.data['message']);
        Get.off(const LoginPage());
      } else {
        CommonUtils.showErrorToast(userSignInResponse.data['message']);
      }
      isLoggingIn.value = false;
    } catch (e) {
      usernameController.text = "";
      passwordController.text = "";
      isLoggingIn.value = false;
      CommonUtils.showErrorToast(e.toString());
    }
  }
}
