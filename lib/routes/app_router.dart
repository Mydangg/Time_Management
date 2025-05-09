import 'package:flutter/material.dart';
import 'package:time_management/Chat/chat_history_screen.dart';
import 'package:time_management/Chat/chatbox_screen.dart';
import 'package:time_management/routes/pages.dart';
import 'package:time_management/splash_screen.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';
import 'package:time_management/tasks/presentation/pages/new_task_screen.dart';
import 'package:time_management/tasks/presentation/pages/task_details.dart';
import 'package:time_management/tasks/presentation/pages/update_task_screen.dart';
import 'package:time_management/tasks/presentation/widget/task_item_view.dart';

import '../HomePage/home_screen.dart';
import '../page_not_found.dart';
import '../tasks/presentation/pages/Schedular/schedular_screen.dart';
import '../tasks/presentation/pages/task_list.dart';


Route onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Pages.initial:
      return MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
    case Pages.home:
      return MaterialPageRoute(
        builder: (context) => const TasksScreen(),
      );
    case Pages.createNewTask:
      return MaterialPageRoute(
        builder: (context) => const NewTaskScreen(),
      );
    case Pages.list_task:
      return MaterialPageRoute(
        builder: (context) => const TaskList(),
      );
    case Pages.taskDetail:
      final args = routeSettings.arguments as TaskModel;
      return MaterialPageRoute(
        builder: (context) => TaskDetails(taskModel: args),
      );
    case Pages.updateTask:
      final args = routeSettings.arguments as TaskModel;
      return MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskModel: args),
      );
    case Pages.schedule:
      return MaterialPageRoute(
        builder: (context) => const Schedular(),
      );
    case Pages.chatbot:
      return MaterialPageRoute(
        builder: (context) => const ChatBot_Screen(),
      );

    case Pages.chatHistory:
      return MaterialPageRoute(
        builder: (context) => const ChatHistoryScreen(),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => const PageNotFound(),
      );
  }
}
