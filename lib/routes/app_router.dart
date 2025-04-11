import 'package:flutter/material.dart';
import 'package:time_management/routes/pages.dart';
import 'package:time_management/splash_screen.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';
import 'package:time_management/tasks/presentation/pages/new_task_screen.dart';
import 'package:time_management/tasks/presentation/pages/update_task_screen.dart';

import '../page_not_found.dart';

Route onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Pages.initial:
      return MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
    // case Pages.home:
    //   return MaterialPageRoute(
    //     builder: (context) => const TasksScreen(),
    //   );
    case Pages.createNewTask:
      return MaterialPageRoute(
        builder: (context) => const NewTaskScreen(),
      );
    case Pages.updateTask:
      final args = routeSettings.arguments as TaskModel;
      return MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskModel: args),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const PageNotFound(),
      );
  }
}
