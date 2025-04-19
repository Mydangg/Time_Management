import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:time_management/tasks/data/local/data_sources/alarm_data_provide.dart';
import 'package:time_management/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:time_management/tasks/data/local/model/alarm_model.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';

final FlutterTts flutterTts = FlutterTts();
bool isSpeaking = false;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class AlarmNotification_Service {
  final TaskDataProvider taskData = TaskDataProvider();
  final AlarmDataProvider alarmData = AlarmDataProvider();

  static final AlarmNotification_Service _instance =
  AlarmNotification_Service._internal();

  factory AlarmNotification_Service() => _instance;

  AlarmNotification_Service._internal();

  void onSelectNotification(NotificationResponse response) {
    // Xử lý khi người dùng nhấn vào thông báo
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

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  Future<void> stopSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
      isSpeaking = false;
    }
  }

  Map<DateTime, List<TaskModel>> expandEvent(List<TaskModel> allEvent) {
    Map<DateTime, List<TaskModel>> expandedEvents = {};

    for (var event in allEvent) {
      DateTime currentDate = DateTime(event.startDateTime!.year,
          event.startDateTime!.month, event.startDateTime!.day);
      DateTime endDate = DateTime(event.stopDateTime!.year,
          event.stopDateTime!.month, event.stopDateTime!.day);

      while (!currentDate.isAfter(endDate)) {
        expandedEvents.putIfAbsent(currentDate, () => []);
        expandedEvents[currentDate]!.add(event);
        currentDate = currentDate.add(Duration(days: 1));
      }
    }

    print("Expanded events: $expandedEvents");
    return expandedEvents;
  }

  Future<void> setAlarm(List<TaskModel> listTask) async {
    Map<DateTime, List<TaskModel>> expandedEvents = expandEvent(listTask);
    int number = 0;

    for (var entry in expandedEvents.entries) {
      final List<TaskModel> taskList = entry.value;

      for (var taskModel in taskList) {
        int alarmId = await alarmData.createAlarm(taskModel);

        if (alarmId != 0) {
          final DateTime alarmTime = DateTime(
            taskModel.startDateTime!.year,
            taskModel.startDateTime!.month,
            taskModel.startDateTime!.day,
            taskModel.startTime!.hour,
            taskModel.startTime!.minute,
          );

          switch (taskModel.repeat?.toLowerCase()) {
            case 'Daily':
              await AndroidAlarmManager.periodic(
                const Duration(days: 1),
                alarmId,
                alarmCallback,
                startAt: alarmTime,
                exact: true,
                wakeup: true,
              );
              break;

            case 'Weekly':
              await AndroidAlarmManager.periodic(
                const Duration(days: 7),
                alarmId,
                alarmCallback,
                startAt: alarmTime,
                exact: true,
                wakeup: true,
              );
              break;

            case 'None':
            default:
              await AndroidAlarmManager.oneShotAt(
                alarmTime,
                alarmId,
                alarmCallback,
                exact: true,
                wakeup: true,
              );
              break;
          }

          print(
              "Đã đặt báo thức cho task '${taskModel.title}' lúc $alarmTime với repeat: ${taskModel.repeat}");
        }
      }
    }
  }

  Future<void> cancelAlarm(String taskId) async {
    List<AlarmModel> listAlarm = await alarmData.cancelAllAlarms(taskId);

    try {
      for (var alarm in listAlarm) {
        await AndroidAlarmManager.cancel(alarm.alarmId);
        print("Đã huỷ báo thức có id: ${alarm.alarmId}");
      }
    } catch (e) {
      print("Lỗi khi huỷ báo thức: ${e.toString()}");
    }
  }

  Future<void> updateAlarm(List<TaskModel> taskModel) async {
    try {

      for(var task in taskModel){
        await cancelAlarm(task.id);
      }
      await setAlarm(taskModel);

    } catch (e) {
      print("Lỗi khi huỷ báo thức: ${e.toString()}");
    }
  }
}

@pragma('vm:entry-point')
void alarmCallback() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin.show(
    0,
    '⏰ Báo thức!',
    'Đã tới giờ thực hiện nhiệm vụ rồi',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_notif',
        'Alarm Notifications',
        channelDescription: 'Thông báo báo thức',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        fullScreenIntent: true,
        playSound: true,
        enableLights: true,
        color: Colors.red,
        timeoutAfter: 6000, // ⏱️ Tự động tắt sau 60s
      ),
    ),
    payload: 'alarm',
  );

  final port = IsolateNameServer.lookupPortByName('alarm_port');
  port?.send('show_alarm_screen');
}
