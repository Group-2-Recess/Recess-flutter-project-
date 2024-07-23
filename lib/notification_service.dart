import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late FirebaseMessaging _firebaseMessaging;

  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize Flutter Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Initialize Firebase Messaging
    _firebaseMessaging = FirebaseMessaging.instance;

    // Configure Firebase Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming message (notification)
      _handleFirebaseMessage(message);
    });
  }

  void _handleFirebaseMessage(RemoteMessage message) {
    // Extract notification details from the Firebase message
    final notification = message.notification;
    if (notification != null) {
      final title = notification.title ?? '';
      final body = notification.body ?? '';
      // Schedule notification based on Firebase message
      scheduleNotification('', '', title, body); // Example: 8:00 AM
    }
  }

  Future<void> scheduleNotification(
      String hourStr, String minuteStr, String title, String body) async {
    // Convert hour and minute strings to integers
    int hour = int.parse(hourStr);
    int minute = int.parse(minuteStr);

    final now = DateTime.now();
    final scheduledDate = DateTime(now.year, now.month, now.day, hour, minute)
        .subtract(Duration(hours: 1)); // Subtract one hour

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // This ensures it repeats daily
    );
  }
}
