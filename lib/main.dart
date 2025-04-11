import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:time_management/firebase_options.dart'; // hoặc task_manager_app/firebase_options.dart tùy nơi bạn để
import 'package:time_management/HomePage/splash_screen.dart';
import 'package:time_management/Login_Signup/Screen/login.dart';
import 'package:time_management/routes/app_router.dart';
import 'package:time_management/routes/pages.dart';
import 'package:time_management/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:time_management/tasks/data/repository/task_repository.dart';
import 'package:time_management/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:time_management/utils/color_palette.dart';

import 'bloc_state_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = BlocStateOberver();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(preferences: preferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) =>
          TaskRepository(taskDataProvider: TaskDataProvider()),
      child: BlocProvider(
        create: (context) => TasksBloc(context.read<TaskRepository>()),
        child: MaterialApp(
          title: 'Task Manager',
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
