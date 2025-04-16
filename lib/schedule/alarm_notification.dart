import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:isolate';
import 'dart:ui';

import '../tasks/presentation/pages/Schedular/alarm_screen.dart';

final FlutterTts flutterTts = FlutterTts();
bool isSpeaking = false;

class AlarmNotification_Service{

  static final AlarmNotification_Service _instance = AlarmNotification_Service._internal();

  factory AlarmNotification_Service() => _instance;

  AlarmNotification_Service._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Fix: Make the callback synchronous
  void onSelectNotification(NotificationResponse response) {
  }

  Future<void> initializeNotifications() async {
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
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onSelectNotification);
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
      color: Colors.red,
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

  Future<void> stopSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
      isSpeaking = false;
    }
  }

  // @pragma('vm:entry-point')
  // void alarmCallback() async {
  //   final port = IsolateNameServer.lookupPortByName('alarm_port');
  //   port?.send('show_alarm_screen');
  //
  //   // Thực thi thông báo
  //   DateTime scheduledDateTime = DateTime.now().add(const Duration(minutes: 1)); // Cập nhật thời gian báo thức
  //   await showAlarmNotification(scheduledDateTime);
  //
  // }

  Future<void> speakAlarmMessage(String message) async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setSpeechRate(0.5); // tốc độ chậm rãi
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    isSpeaking = true;
    await flutterTts.speak(message);
  }

  Future<void> setAlarm() async {

    int alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000); // hoặc dùng uuid

    final now = DateTime.now();
    final alarmTime = now.add(const Duration(minutes: 1));
    print(alarmTime);
    await AndroidAlarmManager.oneShotAt(
      alarmTime,
      alarmId,
      alarmCallback,
      exact: true,
      wakeup: true,
    );
  }
}

@pragma('vm:entry-point')
void alarmCallback() async {
  final service = AlarmNotification_Service();
  print("⏰ [Alarm callback] Được gọi lúc: ${DateTime.now()}");

  final port = IsolateNameServer.lookupPortByName('alarm_port');
  port?.send('show_alarm_screen');

  await service.showAlarmNotification(DateTime.now());
  await service.speakAlarmMessage("Đã tới giờ rồi đó! Dậy đi nào!");
}



