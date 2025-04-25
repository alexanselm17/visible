import 'package:visible/service/notification/NavigationService.dart';
import 'package:visible/service/notification/local_notifications_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:visible/service/notification/service_locator.dart';

Future handleBackgroundMessage(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    await LocalNotificationService.initialize(Get.context!);
    LocalNotificationService.display(message);
  } catch (e) {
    print("catch error $e");
  }
}

class PushNotification {
  Future initialize() async {
    await Firebase.initializeApp();
    final firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission();
    final token = await firebaseMessaging.getToken();
    print('::::::token');
    print('::::::${token.toString()}');
    initPushNotifications();
    LocalNotificationService.initialize(Get.context!);
  }

  handleMessage([RemoteMessage? message]) {
    if (message == null) return;
    final page = message.data['page'];
    locator<NavigationService>().navigateTo(page);
  }

  // for Ios
  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((value) => handleMessage);
    // on foreground
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // on background
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    // listen to message on app running state
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification == null) return;
      LocalNotificationService.display(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      print("FirebaseMessaging.getInitialMessage");
      if (message != null) {
        print(message.data);
        handleMessage();
      }
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("device toke ::::::: $token");
    return token!;
  }

  /// get new fcm token and update user endpoint.
  Future updateFcmToken() async {
    String token = await FirebaseMessaging.instance
        .getToken()
        .then((value) => value.toString());
    return token;
  }
}
