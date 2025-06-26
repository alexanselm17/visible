// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:visible/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visible/model/auth/sign_in_model.dart';

class UserPreferences with ChangeNotifier {
  static const String INTRO_SCREEN_KEY = "isIntroScreenShown";
  static const String USER_ID = "USER_ID";
  static const String ROLE_ID = "ROLE_ID";
  static const String COMPANY_ID = "COMPANY_ID";
  static const String STATION_ID = "STATION_ID";
  static const String STATION_TYPE = "STATION_TYPE";
  static const String _userKey = 'user_data';
  static const String _userDataKey = 'userData';

  static const String SLUG = "SLUG";

  // Singleton pattern
  static final UserPreferences _instance = UserPreferences._internal();
  factory UserPreferences() => _instance;
  UserPreferences._internal();

  Future<bool> storeSignInModel(SignInModel model) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String modelJson = jsonEncode(model.toJson());
    return prefs.setString(_userDataKey, modelJson);
  }

  Future<SignInModel?> getSignInModel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? modelJson = prefs.getString(_userDataKey);

    if (modelJson == null || modelJson.isEmpty) {
      return null;
    }

    try {
      return SignInModel.fromJson(jsonDecode(modelJson));
    } catch (e) {
      print('Error parsing stored SignInModel: $e');
      return null;
    }
  }

  Future<void> storeToken(String token) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(ApiEndpoints.TOKEN_KEY, token);
    notifyListeners();
  }

  Future<String> getToken() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString(ApiEndpoints.TOKEN_KEY) ?? "";
    return token;
  }

  Future<void> storeUserId(String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(USER_ID, id);
    notifyListeners();
  }

  getUserId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString(USER_ID);
    return id;
  }

  Future<void> storeRoleId(String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(ROLE_ID, id);
    notifyListeners();
  }

  getUserRoleId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString(ROLE_ID);
    return id;
  }

  Future<void> storeCompanyId(String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(COMPANY_ID, id);
    notifyListeners();
  }

  getUserCompanyId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString(COMPANY_ID);
    return id;
  }

  Future<void> storeStationId(String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(STATION_ID, id);
    notifyListeners();
  }

  getUserStationId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? id = preferences.getString(STATION_ID);
    return id;
  }

  Future<void> storeUserSlug(String slug) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(SLUG, slug);
    notifyListeners();
  }

  getUserSlug() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? slug = preferences.getString(SLUG);
    return slug;
  }

  Future<void> clearToken() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(ApiEndpoints.TOKEN_KEY);
  }

  Future<void> setIntroScreenShown(bool isShown) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(INTRO_SCREEN_KEY, isShown);
    print('Intro screen shown set to: $isShown');
  }

  Future<bool> isIntroScreenShown() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final result = preferences.getBool(INTRO_SCREEN_KEY) ?? false;
    print('Intro screen shown: $result');
    return result;
  }

  Future<void> storePetroStationType(String type) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(STATION_TYPE, type);
    notifyListeners();
  }

  Future<String> getPetroStationType() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString(STATION_TYPE) ?? "";
    return token;
  }

  static Future<void> saveUserData({
    required String? name,
    required String? email,
    required String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      'name': name ?? '',
      'email': email ?? '',
      'phone': phone ?? '',
    };
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  static Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userKey);

    if (jsonString != null) {
      final Map<String, dynamic> userData = jsonDecode(jsonString);
      return userData.map((key, value) => MapEntry(key, value.toString()));
    }

    return null;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await Future.wait([
        prefs.remove(ApiEndpoints.TOKEN_KEY),
        prefs.remove(USER_ID),
        prefs.remove(ROLE_ID),
        prefs.remove(COMPANY_ID),
        prefs.remove(STATION_ID),
        prefs.remove(STATION_TYPE),
        prefs.remove(SLUG),
        prefs.remove(_userDataKey),
        prefs.remove(_userKey),
        prefs.remove('fcm_token'),
      ]);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
