import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_fridge/models/fridge.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static const channel_id = "123";

  Future<void> init(Future<dynamic> Function(int, String, String, String) onDidReceive) async {

    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceive);

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    tz.initializeTimeZones();
  }

  Future selectNotification(String payload) async {
    Fridge fridge = getFridgeFromPayload(payload ?? '');
    cancelNotificationForItem(fridge);
    scheduleNotificationForItem(fridge, "${fridge.name} will expire soon!");
  }

  void showNotification(Fridge fridge, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        fridge.hashCode,
        'SmartFridge',
        notificationMessage,
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, 'SmartFridge',
                'To remind you about items in your fridge')
        ),
        payload: jsonEncode(fridge.toJson())
    );
  }

  void scheduleNotificationForItem(Fridge fridge, String notificationMessage) async {
    DateTime now = DateTime.now();
    DateTime expiryDate = fridge.expiryDate.toDate().subtract(const Duration(days: 1));
    Duration difference = now.isAfter(expiryDate)
        ? now.difference(expiryDate)
        : expiryDate.difference(now);

    _wasApplicationLaunchedFromNotification()
        .then((bool didApplicationLaunchFromNotification){
      if (!didApplicationLaunchFromNotification && difference.inDays == 0) {
        showNotification(fridge, notificationMessage);
      }
    });

    await flutterLocalNotificationsPlugin.zonedSchedule(
        fridge.hashCode,
        'SmartFridge',
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(difference),
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, 'SmartFridge',
                'To remind you about items in your fridge')),
        payload: jsonEncode(fridge.toJson()),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  void cancelNotificationForItem(Fridge fridge) async {
    await flutterLocalNotificationsPlugin.cancel(fridge.hashCode);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void handleApplicationWasLaunchedFromNotification(String payload) async {
    if (Platform.isIOS) {
      _rescheduleNotificationFromPayload(payload);
      return;
    }

    final NotificationAppLaunchDetails notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null && notificationAppLaunchDetails.didNotificationLaunchApp) {
      _rescheduleNotificationFromPayload(notificationAppLaunchDetails.payload ?? "");
    }
  }

  Fridge getFridgeFromPayload(String payload) {
    Fridge fridge = Fridge.fromJson(jsonDecode(payload));
    //Fridge fridge = Fridge.fromJson(json);
    return fridge;
  }

  Future<bool> _wasApplicationLaunchedFromNotification() async {
    NotificationAppLaunchDetails notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null) {
      return notificationAppLaunchDetails.didNotificationLaunchApp;
    }

    return false;
  }

  void _rescheduleNotificationFromPayload(String payload) {
    Fridge fridge = getFridgeFromPayload(payload);
    cancelNotificationForItem(fridge);
    scheduleNotificationForItem(fridge, "${fridge.name} will expire soon!");
  }
}
