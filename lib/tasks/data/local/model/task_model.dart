import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskModel {
  String id;
  String title;
  String description;
  DateTime? startDateTime;
  DateTime? stopDateTime;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool completed;
  String priority;
  String repeat;
  String createBy;
  String createById;



  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.stopDateTime,
    this.startTime,
    this.endTime,
    this.completed = false,
    required this.priority,
    required this.repeat,
    required this.createBy,
    required this.createById,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'startDateTime': startDateTime != null ? Timestamp.fromDate(startDateTime!) : null,
      'stopDateTime': stopDateTime != null ? Timestamp.fromDate(stopDateTime!) : null,
      'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null, // Lưu giờ dưới dạng chuỗi
      'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null, // Lưu giờ dưới dạng chuỗi
      'priority': priority,
      'repeat': repeat,
      'createBy': createBy,
      'createById': createById,
    };
  }


  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
      startDateTime: (json['startDateTime'] as Timestamp?)?.toDate(),
      stopDateTime: (json['stopDateTime'] as Timestamp?)?.toDate(),
      startTime: json['startTime'] != null ? _parseTime(json['startTime']) : null,
      endTime: json['endTime'] != null ? _parseTime(json['endTime']) : null,
      priority: json['priority'] ?? '',
      repeat: json['repeat'] ?? '',
      createBy: json['createBy'] ?? '',
      createById: json['createById'] ?? '',
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  String toString() {
    return
      'TaskModel'
          '{id: $id, title: $title, description: $description, '
        'startDateTime: $startDateTime, stopDateTime: $stopDateTime, startTime: $startTime, endTime: $endTime,'
        'completed: $completed, priority: $priority, repeat:  ,createBy: $createBy, createById: $createById}';
  }
}
