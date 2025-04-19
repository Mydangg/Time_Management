import 'dart:async';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  FlutterTts flutterTts = FlutterTts();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap, // sửa lại cho đúng API mới
      // onDidReceiveBackgroundNotificationResponse dùng cho background isolate
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    print('Notification click: ${response.payload}');
  }

  void _speakNotification(String message) async {
    await flutterTts.setLanguage("vi-VN"); // Ngôn ngữ tiếng Việt
    await flutterTts.setSpeechRate(0.5);  // Tốc độ đọc
    await flutterTts.setVolume(1.0);      // Âm lượng

    await flutterTts.speak(message);
  }

  Future<void> showNotification(DateTime dateTime, String title, String createBy) async {
    print('datatime ${dateTime}');
    final tz.TZDateTime scheduledDateTime =
    tz.TZDateTime.from(dateTime, tz.local);

    const AndroidNotificationDetails androidSpecs = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Channel for instant notification',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // turn off "ting"
      sound: null,
      fullScreenIntent: true,
    );

    const NotificationDetails platformSpecs = NotificationDetails(
      android: androidSpecs,
    );

    var greet = "";
    int hour = scheduledDateTime.hour;
    if (hour >= 5 && hour < 12) {
      greet = "Hi ${createBy}! Đã đến giờ làm việc.";
    } else if (hour >= 12 && hour < 18) {
      greet = "Hi ${createBy} buổi chiều tốt lành";
    } else if (hour >= 18 && hour <= 22) {
      greet = "Hi ${createBy}";
    } else {
      greet = "Hi ${createBy}";
    }

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Cấu hình thông báo
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Thông báo!',
      'Còn 1 phút nữa đến lịch hẹn',
      // tz.TZDateTime.from(scheduledDateTime, tz.local),
      scheduledDateTime.subtract(Duration(minutes: 1)),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'your channel id', 'your channel name', channelDescription: 'your channel description')),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // Đặt thêm 1 Timer khi đến đúng giờ (nếu app đang mở)
    Duration delay = scheduledDateTime.difference(DateTime.now());

    if (delay.isNegative == false) {
      Timer(delay, () {
        _speakNotification('${greet} Bây giờ là ${scheduledDateTime.hour} giờ ${scheduledDateTime.minute} bạn có ${title} nhớ hoàn thành công việc nhé');
      });
    }


  }

  Future<void> showAlarmNotification(DateTime scheduledDateTime) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'alarm_notif',
      'Alarm Notifications',
      channelDescription: 'Thông báo báo thức',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      fullScreenIntent: true, // Mở màn hình đầy đủ khi báo thức đến
      playSound: true,
      enableLights: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      '⏰ Báo thức!',
      'Đã tới giờ rồi đó!',
      platformChannelSpecifics,
      payload: 'alarm',
    );
  }
}

