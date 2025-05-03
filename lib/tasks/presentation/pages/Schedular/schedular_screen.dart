
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_management/proflie/theme.dart';
import 'package:time_management/tasks/presentation/bloc/tasks_bloc.dart';
import '../../widget/schedular_item_view.dart';
import 'package:provider/provider.dart';

class Schedular extends StatefulWidget {
  const Schedular({super.key});
  @override
  _Schedular createState() => _Schedular();
}

class _Schedular extends State<Schedular> {

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'TableCalendar - Events',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: isDark ? Colors.white : Colors.black,),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Đặt chiều cao của viền
          child: Container(
            color: Colors.black26, // Màu của viền dưới
            height: 1.0, // Độ dày của viền dưới
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FetchTasksSuccess) {
              return SchedularItemView(task: state.tasks);
            }
            return const Center(child: Text('Something went wrong.'));
          }
        ),
      ),
    );
  }
}
