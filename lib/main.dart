import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:time_management/HomePage/home_screen.dart';
import 'package:time_management/firebase_options.dart';
import 'package:time_management/HomePage/splash_screen.dart';
import 'package:time_management/Login_Signup/Screen/login.dart';
import 'package:time_management/Login_Signup/Screen/home_screen.dart'; // Trang chính sau khi đăng nhập
import 'package:time_management/proflie/theme.dart';
import 'package:time_management/routes/app_router.dart';
import 'package:time_management/schedule/alarm_notification.dart';
import 'package:time_management/schedule/wake_up_notification.dart';
import 'package:time_management/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:time_management/tasks/data/repository/task_repository.dart';
import 'package:time_management/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:time_management/tasks/presentation/pages/Schedular/schedular_screen.dart';
import 'package:time_management/tasks/presentation/pages/new_task_screen.dart';
import 'package:time_management/utils/color_palette.dart';
import 'package:time_management/tasks/presentation/pages/Dashboard/dashboard_screen.dart';
import 'package:timezone/data/latest.dart' as tz;


import 'bloc_state_observer.dart';

// Khởi tạo GlobalKey cho navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocStateOberver();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();

  // Kiểm tra nếu không phải là Web và chạy trên Android mới sử dụng AndroidAlarmManager
  if (!kIsWeb && Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
    await AlarmNotification_Service().initializeNotifications();
  }

  // che do xoay man hinh
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Chế độ dọc
    DeviceOrientation.landscapeLeft, // Chế độ ngang trái
    DeviceOrientation.landscapeRight, // Chế độ ngang phải
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: MyApp(preferences: preferences),
      ),
    ),
  );

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

    if (!kIsWeb) {
      WakeUpNotification().callback(navigatorKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return RepositoryProvider(
      create: (context) => TaskRepository(taskDataProvider: TaskDataProvider()),
      child: BlocProvider(
        create: (context) => TasksBloc(context.read<TaskRepository>()),
        child: MaterialApp(
          title: 'Task Manager',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: onGenerateRoute,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              primarySwatch: Colors.blue,
            ).copyWith(
              textTheme: ThemeData.light().textTheme.apply(
                fontFamily: 'Sora',
              ),
            ),
          // Chủ đề sáng
          darkTheme: ThemeData.dark().copyWith(
              textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: 'Sora',
              ),
          ),// Chủ đề tối
          themeMode:
          themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Áp dụng chế độ sáng/tối
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
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

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasData) {
//           return const HomeScreen(); // Đã đăng nhập, chuyển đến trang chính
//         } else {
//           return const LoginScreen(); // Chưa đăng nhập, chuyển đến trang đăng nhập
//         }
//       },
//     );
//   }
// }