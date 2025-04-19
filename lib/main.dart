import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:time_management/firebase_options.dart'; // hoặc task_manager_app/firebase_options.dart tùy nơi bạn để
import 'package:time_management/HomePage/splash_screen.dart';
import 'package:time_management/Login_Signup/Screen/login.dart';
import 'package:time_management/routes/app_router.dart';
import 'package:time_management/schedule/alarm_notification.dart';
import 'package:time_management/schedule/notifaication_schedular.dart';
import 'package:time_management/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:time_management/tasks/data/repository/task_repository.dart';
import 'package:time_management/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:time_management/tasks/presentation/pages/Schedular/alarm_screen.dart';
import 'package:time_management/utils/color_palette.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'bloc_state_observer.dart';

final ReceivePort _alarmPort = ReceivePort();

// Khởi tạo GlobalKey cho navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Thông Báo
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocStateOberver();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  tz.initializeTimeZones();
  await NotificationService().initialize();
  await AndroidAlarmManager.initialize();
  await AlarmNotification_Service().initializeNotifications();

  runApp(MyApp(preferences: preferences));
}

class MyApp extends StatefulWidget {
  final SharedPreferences preferences;

  const MyApp({super.key, required this.preferences});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Đăng ký ReceivePort để lắng nghe tín hiệu báo thức
    IsolateNameServer.registerPortWithName(_alarmPort.sendPort, 'alarm_port');

    _alarmPort.listen((message) {
      if (message == 'show_alarm_screen') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const AlarmScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) =>
          TaskRepository(taskDataProvider: TaskDataProvider()),
      child: BlocProvider(
        create: (context) => TasksBloc(context.read<TaskRepository>()),
        child: MaterialApp(
          title: 'Task Manager',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: onGenerateRoute,
          theme: ThemeData(
            fontFamily: 'Sora',
            visualDensity: VisualDensity.adaptivePlatformDensity,
            canvasColor: Colors.transparent,
            colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
            useMaterial3: true,
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return const SplashScreen(); // Đã đăng nhập
              } else {
                return const LoginScreen(); // Chưa đăng nhập
              }
            },
          ),
        ),
      ),
    );
  }
}
