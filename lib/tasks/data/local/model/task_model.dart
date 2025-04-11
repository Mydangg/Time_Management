import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id;
  String title;
  String description;
  DateTime? startDateTime;
  DateTime? stopDateTime;
  bool completed;
  String priority;
  String createBy;
  String createById;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    required this.stopDateTime,
    this.completed = false,
    required this.priority,
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
      'priority': priority,
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
      priority: json['priority'] ?? '',
      createBy: json['createBy'] ?? '',
      createById: json['createById'] ?? '',
    );
  }


  @override
  String toString() {
    return
      'TaskModel'
          '{id: $id, title: $title, description: $description, '
        'startDateTime: $startDateTime, stopDateTime: $stopDateTime, '
        'completed: $completed}, priority: $priority, createBy: $createBy, createById: $createById';
  }
}
