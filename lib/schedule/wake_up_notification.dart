import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../tasks/presentation/pages/Schedular/alarm_screen.dart';

class WakeUpNotification {

  final ReceivePort _alarmPort = ReceivePort();

  // Chuyển đổi kiểu trả về từ Future<Void> thành Future<void>
  Future<void> callback(GlobalKey<NavigatorState> navigatorKey) async {
    // Đăng ký tên cho port, chỉ sử dụng khi là Android
    IsolateNameServer.registerPortWithName(_alarmPort.sendPort, 'alarm_port');

    // Lắng nghe thông điệp từ port

    _alarmPort.listen((message) {
      if (message == 'show_alarm_screen') {
        // Đảm bảo navigatorKey không null và xử lý điều hướng
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const AlarmScreen()),
        );
      }
    });
  }
}

