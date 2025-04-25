// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:logger/logger.dart';
// import 'package:visible/common/toast.dart';
// import 'package:visible/models/auth/sign_in_model.dart' as login;
// import 'package:visible/models/auth/sign_up_model.dart';
// import 'package:visible/models/users/home_page_user_details.dart' as homePage;
// import 'package:visible/models/users/home_page_user_details.dart';
// import 'package:visible/repositories/auth_repository.dart';
// import 'package:visible/repository/auth_repository.dart';
// import 'package:visible/screens/auth/login_screen.dart';
// import 'package:visible/screens/employees/user_controller.dart';
// import 'package:visible/screens/navigation_page.dart';
// import 'package:visible/services/network/dio_exception.dart';
// import 'package:visible/services/shared_preferences/user_pref.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:visible/shared_preferences/user_pref.dart';

// class AuthenticationController extends GetxController {
//   final AuthRepository authRepository = AuthRepository();
//   UsersController usersController = Get.put(UsersController());

//   final signUpFormKey = GlobalKey<FormState>();

//   final fullNameController = TextEditingController();
//   final userNameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final nationalIdController = TextEditingController();
//   final emailController = TextEditingController();
//   final cardNumberController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   final usernameController = TextEditingController();
//   final loginPasswordController = TextEditingController();

//   final isLoading = false.obs;
//   final pVisible = false.obs;
//   get passVisible => pVisible;

//   final isLoggingIn = false.obs;
//   final passwordVisible = false.obs;

//   Rx<homePage.Data> currentUserDetails = homePage.Data().obs;
//   Rx<login.Data> currentUserLoginDetails = login.Data().obs;

//   @override
//   void onInit() {
//     // getUserDetails();
//     super.onInit();
//   }

//   void togglePasswordVisibility() {
//     pVisible.value = !pVisible.value;
//   }

//   Future<void> handleSignUp() async {
//     try {
//       isLoading.value = true;

//       final res = await authRepository.userSignUp(
//         fullname: fullNameController.text,
//         username: userNameController.text,
//         phone: phoneController.text,
//         nationalId: int.parse(nationalIdController.text.trim()),
//         password: passwordController.text,
//         cpassword: confirmPasswordController.text,
//         email: emailController.text,
//         cardNumber: cardNumberController.text,
//         companyId: '',
//         petroStationId: '',
//       );

//       isLoading.value = false;

//       if (res!.statusCode == 200) {
//         final data = SignUpModel.fromJson(res.data);
//         CommonUtils.showToast(data.message!);
//         Get.offUntil(
//             MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
//         isLoading.value = true;
//         userNameController.clear();
//         passwordController.clear();
//         fullNameController.clear();
//         phoneController.clear();
//         emailController.clear();
//         nationalIdController.clear();
//         cardNumberController.clear();
//         confirmPasswordController.clear();
//       }
//       if (res.statusCode == 422) {
//         return CommonUtils.showErrorToast(res.data['message']);
//       } else {
//         return CommonUtils.showErrorToast(res.data['message']);
//       }
//     } catch (e) {
//       isLoading.value = false;
//     }
//   }

//   Future<void> addEmployee() async {
//     try {
//       isLoading.value = true;

//       final String companyId = await UserPreferences().getUserCompanyId();
//       final String visibleStationId =
//           await UserPreferences().getUserStationId();

//       final res = await authRepository.userSignUp(
//         fullname: fullNameController.text.trim(),
//         username: userNameController.text.trim(),
//         phone: "+254${phoneController.text.replaceAll(' ', '')}",
//         nationalId: int.parse(nationalIdController.text.trim()),
//         password: passwordController.text,
//         cpassword: confirmPasswordController.text,
//         email: emailController.text.trim(),
//         cardNumber: cardNumberController.text.trim(),
//         companyId: companyId,
//         petroStationId: visibleStationId,
//       );
//       isLoading.value = false;

//       if (res?.statusCode == 200) {
//         final data = SignUpModel.fromJson(res!.data);
//         await usersController.getAllUsers();
//         _clearFormFields();
//         CommonUtils.showToast(data.message ?? 'Employee added successfully');
//         Get.back(closeOverlays: true);
//       } else {
//         CommonUtils.showErrorToast(
//             res?.data['message'] ?? 'Failed to add employee');
//       }
//     } catch (e) {
//       CommonUtils.showErrorToast('Error: ${e.toString()}');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void _clearFormFields() {
//     userNameController.clear();
//     passwordController.clear();
//     fullNameController.clear();
//     phoneController.clear();
//     emailController.clear();
//     nationalIdController.clear();
//     cardNumberController.clear();
//     confirmPasswordController.clear();
//   }

//   void toggleLoginPasswordVisibility() {
//     passwordVisible.value = !passwordVisible.value;
//   }

//   Future<void> handleSignIn() async {
//     try {
//       isLoggingIn.value = true;

//       final userSignInResponse = await authRepository.userSign(
//         username: usernameController.text,
//         password: passwordController.text,
//       );

//       isLoggingIn.value = false;

//       Logger().i(userSignInResponse!.data);

//       if (userSignInResponse.statusCode == 200) {
//         final data = login.LoginResponse.fromJson(userSignInResponse.data);
//         currentUserLoginDetails.value = data.data!;
//         update();
//         await UserPreferences().storeToken(data.token!);
//         await UserPreferences()
//             .storeUserId(currentUserLoginDetails.value.id!.toString());
//         await UserPreferences()
//             .storeRoleId(currentUserLoginDetails.value.role!.id!.toString());
//         await UserPreferences()
//             .storeUserSlug(currentUserLoginDetails.value.role!.slug!);
//         await UserPreferences().storeCompanyId(
//             currentUserLoginDetails.value.company!.id!.toString());
//         currentUserLoginDetails.value.visibleStation != null
//             ? {
//                 await UserPreferences().storeStationId(currentUserLoginDetails
//                     .value.visibleStation!.id!
//                     .toString()),
//               }
//             : null;
//         isLoggingIn.value = false;
//         usernameController.clear();
//         passwordController.clear();

//         Get.off(const NavigationPage());
//       } else {
//         CommonUtils.showErrorToast(userSignInResponse.data['message']);
//         usernameController.text = "";
//         passwordController.text = "";
//       }
//       isLoggingIn.value = false;
//     } catch (e) {
//       usernameController.text = "";
//       passwordController.text = "";
//       isLoggingIn.value = false;
//       CommonUtils.showErrorToast(e.toString());
//     }
//   }

//   Future logOut() async {
//     try {
//       String id = await UserPreferences().getUserId();

//       final response = await authRepository.logoutUserApi(userId: id);
//       if (response!.statusCode == 200) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.clear();
//         CommonUtils.showToast('Logged out sucessfully');
//         Get.offAll(LoginScreen());
//       }
//     } on DioException catch (e) {
//       final errorMessage = DioExceptions.fromDioError(e).toString();
//       throw errorMessage;
//     }
//   }

//   Future<void> getUserDetails() async {
//     isLoading.value = true;

//     String userId = await UserPreferences().getUserId();
//     String roleId = await UserPreferences().getUserRoleId();
//     String companyId = await UserPreferences().getUserCompanyId();
//     String visibleStationId = await UserPreferences().getUserStationId();

//     var response = await authRepository.getUserHomeDetails(
//       roleId: roleId,
//       userId: userId,
//       companyId: companyId,
//       visibleStationId: visibleStationId,
//     );
//     isLoading.value = false;
//     Logger().f(response!.realUri);

//     Logger().i(response.data);

//     if (response.statusCode == 200) {
//       final userDetail = homePage.HomePageUserDetails.fromJson(response.data!);
//       currentUserDetails.value = userDetail.data!;
//       await UserPreferences.saveUserData(
//         name: currentUserDetails.value.visibleStation!.first.name!,
//         email: currentUserDetails.value.visibleStation!.first.email!,
//         phone: currentUserDetails.value.visibleStation!.first.phone!,
//       );
//       currentUserDetails.refresh();
//     } else {
//       CommonUtils.showErrorToast(response.data['message']);
//     }
//     // } finally {}
//   }

//   Future<void> resetPassword({
//     required String username,
//     required String phone,
//     required String nationalId,
//     required String password,
//     required String passwordConfirmation,
//   }) async {
//     try {
//       isLoggingIn.value = true;
//       final formattedPhone = phone
//               .replaceAll(RegExp(r'\s+'), '') // Remove spaces
//               .startsWith('+254')
//           ? phone.replaceAll(
//               RegExp(r'\s+'), '') // Remove spaces again for consistency
//           : '+254${phone.replaceAll(RegExp(r'\s+'), '').replaceFirst(RegExp(r'^0'), '')}';

//       final userSignInResponse = await authRepository.resetPassword(
//         username: username,
//         password: password,
//         phone: formattedPhone,
//         nationalId: nationalId,
//         passwordConfirmation: passwordConfirmation,
//       );

//       isLoggingIn.value = false;

//       Logger().f(userSignInResponse!.data);

//       if (userSignInResponse.data['ok'] == true) {
//         CommonUtils.showToast(userSignInResponse.data['message']);
//         Get.off(LoginScreen());
//       } else {
//         CommonUtils.showErrorToast(userSignInResponse.data['message']);
//       }
//       isLoggingIn.value = false;
//     } catch (e) {
//       usernameController.text = "";
//       passwordController.text = "";
//       isLoggingIn.value = false;
//       CommonUtils.showErrorToast(e.toString());
//     }
//   }

//   Future<void> createvisibleStation({
//     required String name,
//     required String type,
//   }) async {
//     try {
//       isLoggingIn.value = true;
//       String companyId = await UserPreferences().getUserCompanyId();

//       final userSignInResponse = await authRepository.createvisibleStation(
//         name: name.toUpperCase(),
//         type: type,
//         companyId: companyId,
//       );

//       isLoggingIn.value = false;

//       if (userSignInResponse!.statusCode == 200) {
//         Get.back();
//         currentUserDetails.value.visibleStation!.add(
//           visibleStation(name: name, type: type),
//         );
//         currentUserDetails.refresh();
//         return CommonUtils.showToast(userSignInResponse.data['message']);
//       } else {
//         CommonUtils.showErrorToast(userSignInResponse.data['message']);
//       }
//       isLoggingIn.value = false;
//     } catch (e) {
//       usernameController.text = "";
//       passwordController.text = "";
//       isLoggingIn.value = false;
//       CommonUtils.showErrorToast(e.toString());
//     }
//   }
// }
