
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_management/tasks/data/local/model/alarm_model.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';
import 'package:time_management/tasks/presentation/pages/Schedular/alarm_screen.dart';

import '../../../../utils/exception_handler.dart';

class AlarmDataProvider {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AlarmModel> alarms = [];

  Future<int> createAlarm(TaskModel taskModel) async {
    int alarmId = 0;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        // Tạo thời gian báo thức
        DateTime taskDate = taskModel.startDateTime!;
        TimeOfDay taskTime = taskModel.startTime!; // giả sử dùng kiểu TimeOfDay
        DateTime alarmTime = DateTime(
          taskDate.year,
          taskDate.month,
          taskDate.day,
          taskTime.hour,
          taskTime.minute,
        );

        // Sinh alarmId duy nhất
        alarmId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        // Tạo AlarmModel
        var alarmModel = AlarmModel(
          createById: userId,
          alarmId: alarmId,
          tasksId: taskModel.id,
          title: taskModel.title,
        );
        final alarmJson = alarmModel.toJson();

        // Lưu vào Firestore
        final docRef = await _firestore
            .collection('alarms')
            .add(alarmJson);

        alarms.add(alarmModel);

        return alarmId;
      }
    } catch (exception) {
      print("Error while adding task: $exception");
      throw Exception(handleException(exception));
    }
    return alarmId;
  }

  Future<List<AlarmModel>> cancelAllAlarms(String taskId) async {
    final snapshot = await _firestore
        .collection('alarms')
        .where('taskId', isEqualTo: taskId)
        .get();

    final alarmList = snapshot.docs.map((doc) {
      return AlarmModel.fromJson(doc.data(), doc.id);
    }).toList();

    // Xoá hết alarm
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    return alarmList;
  }


}