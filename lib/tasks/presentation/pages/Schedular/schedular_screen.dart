
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_management/tasks/presentation/bloc/tasks_bloc.dart';
import '../../widget/schedular_item_view.dart';

class Schedular extends StatefulWidget {
  const Schedular({super.key});
  @override
  _Schedular createState() => _Schedular();
}

class _Schedular extends State<Schedular> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'TableCalendar - Events',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        // backgroundColor: Color(0xFF2097F5),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: IconButton(
            onPressed: () async {
              Navigator.pushReplacementNamed(context, '/home');
            },
            icon: const Icon(Icons.arrow_back),
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
