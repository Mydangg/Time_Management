import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';
import 'package:time_management/utils/exception_handler.dart';

class TaskDataProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TaskModel> tasks = [];

  Future<List<TaskModel>> getTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      tasks = snapshot.docs.map((doc) {
        return TaskModel.fromJson(doc.data(), doc.id); // 👈 truyền ID đúng từ Firestore
      }).toList();

      tasks.sort((a, b) {
        if (a.completed == b.completed) {
          return 0;
        } else if (a.completed) {
          return 1;
        } else {
          return -1;
        }
      });

      return tasks;
    } catch (e) {
      throw Exception(handleException(e));
    }
  }

  Future<List<TaskModel>> sortTasks(int sortOption) async {
    switch (sortOption) {
      case 0:
        tasks.sort((a, b) {
          if (a.startDateTime!.isAfter(b.startDateTime!)) {
            return 1;
          } else if (a.startDateTime!.isBefore(b.startDateTime!)) {
            return -1;
          }
          return 0;
        });
        break;
      case 1:
        tasks.sort((a, b) {
          if (!a.completed && b.completed) {
            return 1;
          } else if (a.completed && !b.completed) {
            return -1;
          }
          return 0;
        });
        break;
      case 2:
        tasks.sort((a, b) {
          if (a.completed == b.completed) {
            return 0;
          } else if (a.completed) {
            return 1;
          } else {
            return -1;
          }
        });
        break;
    }
    return tasks;
  }

  Future<void> createTask(TaskModel taskModel) async {
    try {

      final user = FirebaseAuth.instance.currentUser;
      if(user != null)
      {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final userName = userDoc.data()?['name'] ?? 'Unknown';
        taskModel.createBy = userName;
        taskModel.createById = user.uid;
        final taskJson = taskModel.toJson();
        print(" Data to be added to Firestore: $taskJson");

        final docRef = await _firestore.collection('tasks').add(taskJson);
        taskModel.id = docRef.id;
        tasks.add(taskModel);
      }

    } catch (exception) {
      print("Error while adding task: $exception");
      throw Exception(handleException(exception));
    }
  }


  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    try {
      await _firestore.collection('tasks').doc(taskModel.id).update(taskModel.toJson());
      final taskIndex = tasks.indexWhere((element) => element.id == taskModel.id);
      if (taskIndex != -1) {
        tasks[taskIndex] = taskModel;
      }
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> deleteTask(TaskModel taskModel) async {
    try {
      await _firestore.collection('tasks').doc(taskModel.id).delete();
      tasks.remove(taskModel);
      return tasks;
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  Future<List<TaskModel>> searchTasks(String keywords) async {
    var searchText = keywords.toLowerCase();
    List<TaskModel> matchedTasks = tasks;
    return matchedTasks.where((task) {
      final titleMatches = task.title.toLowerCase().contains(searchText);
      final descriptionMatches = task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
  }
}
