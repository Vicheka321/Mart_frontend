import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:mart_frontend/services/api_service.dart';
import 'package:mart_frontend/services/notification_service.dart';
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request notification permission
  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("Permission: ${settings.authorizationStatus}");
  }

  /// Get FCM Token
  Future<String?> getToken() async {
    String? token = await _messaging.getToken();

    print("FCM TOKEN:");
    print(token);

    return token;
  }

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await flutterLocalNotificationsPlugin.initialize(settings);
    // await flutterLocalNotificationsPlugin.initialize(
    //   settings,

    //   onDidReceiveNotificationResponse: (details) {
    //     print(details.payload);

    //     // Next Step
    //     // Open Order Detail Screen
    //   },
    // );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // void listenForegroundNotification() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("Foreground Notification Received");

  //     print(message.notification?.title);
  //     print(message.notification?.body);
  //   });
  // }

  void listenForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification == null) return;

      Get.snackbar(
        message.notification!.title ?? "",
        message.notification!.body ?? "",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),

        backgroundColor: Colors.white,
        colorText: Colors.black,

        margin: const EdgeInsets.all(12),
        borderRadius: 12,

        icon: const Icon(Icons.notifications_active, color: Colors.green),
      );
    });
  }

  void handleNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message.data);
    });
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? message = await FirebaseMessaging.instance
        .getInitialMessage();

    if (message != null) {
      print(message.data);
    }
  }

  Future<void> saveCurrentToken() async {
    final token = await getToken();

    if (token == null) return;

    await saveToken(token);
  }

  Future<void> saveToken(String token) async {
    final api = ApiService();

    final hasLogin = await api.isLoggedIn();

    if (hasLogin) {
      await api.saveUserToken(token);
    } else {
      await api.saveGuestToken(token);
    }
  }

  Future<void> init() async {
    await initialize();

    await requestPermission();

    await saveCurrentToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      print("NEW TOKEN : $token");

      await saveToken(token);
    });

    listenForegroundNotification();

    handleNotificationClick();

    await checkInitialMessage();
  }
}
