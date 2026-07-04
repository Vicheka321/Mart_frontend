import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  void listenForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Notification Received");

      print(message.notification?.title);
      print(message.notification?.body);
    });
  }

  // void listenForegroundNotification() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //     print("Foreground Notification");

  //     if (message.notification == null) return;

  //     await flutterLocalNotificationsPlugin.show(
  //       message.hashCode,

  //       message.notification!.title,

  //       message.notification!.body,

  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'high_importance_channel',
  //           'High Importance Notifications',

  //           importance: Importance.high,
  //           priority: Priority.high,
  //           icon: '@mipmap/ic_launcher',
  //         ),
  //       ),

  //       payload: message.data['order_id'],
  //     );
  //   });
  // }

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

}
