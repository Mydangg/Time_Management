import 'package:cloud_firestore/cloud_firestore.dart';

import '../tasks/data/local/model/task_model.dart';

class FirestoreService{
  // Get collection of notes
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// CREATE
  Future<void> saveTaskToFirestore(TaskModel taskModel) async {
    try {
      final taskCollection = _firestore.collection('tasks');
      final docRef = await taskCollection.add({
        'title': taskModel.title,
        'description': taskModel.description,
        'completed': taskModel.completed,
        'startDateTime': taskModel.startDateTime != null
            ? Timestamp.fromDate(taskModel.startDateTime!)
            : null,
        'stopDateTime': taskModel.stopDateTime != null
            ? Timestamp.fromDate(taskModel.stopDateTime!)
            : null,
        'priority': taskModel.priority,
      });

      // cập nhật lại ID vào taskModel nếu bạn cần
      taskModel.id = docRef.id;
    } catch (e) {
      throw Exception('Error saving task: $e');
    }
  }

// READ
// UPDATE
  Future<void> updateTaskInFirestore(TaskModel taskModel) async {
    try {
      final taskDoc = _firestore.collection('tasks').doc(taskModel.id);
      await taskDoc.update({
        'title': taskModel.title,
        'description': taskModel.description,
        'completed': taskModel.completed,
        'startDateTime': taskModel.startDateTime != null
            ? Timestamp.fromDate(taskModel.startDateTime!)
            : null,
        'stopDateTime': taskModel.stopDateTime != null
            ? Timestamp.fromDate(taskModel.stopDateTime!)
            : null,
      });
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

// DELETE

  Future<void> deleteTaskFromFirestore(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

}
