import 'package:flutter/material.dart';

class AlarmModel {
  late String id;
  late String createById;
  late int alarmId;
  late String tasksId;
  late String title;

  // AlarmModel(this.createById, this.alarmId,this.tasksId,this.title);
  AlarmModel({
    required this.createById,
    required this.alarmId,
    required this.tasksId,
    required this.title
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createById': createById,
      'alarmId': alarmId,
      'taskId': tasksId
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json, String id) {
    return AlarmModel(
      createById: json['createById'] ?? '',
      alarmId: json['alarmId']?? 0,
      tasksId: json['taskId']??'',
      title: json['title'] ?? '',
    );
  }
}