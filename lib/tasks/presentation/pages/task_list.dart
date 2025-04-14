import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:time_management/components/build_text_field.dart';
import 'package:time_management/components/widgets.dart';
import 'package:time_management/routes/pages.dart';
import 'package:time_management/utils/color_palette.dart';
import 'package:time_management/utils/font_sizes.dart';
import 'package:time_management/utils/util.dart';

import '../bloc/tasks_bloc.dart';
import '../widget/task_item_view.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TasksBloc>().add(FetchTaskEvent());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        actions: [
          PopupMenuButton<int>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 1,
            onSelected: (value) {
              context.read<TasksBloc>().add(SortTaskEvent(sortOption: value));
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/svgs/calender.svg', width: 15),
                    const SizedBox(width: 10),
                    buildText('Sort by date', kBlackColor, textSmall, FontWeight.normal, TextAlign.start, TextOverflow.clip)
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/svgs/task_checked.svg', width: 15),
                    const SizedBox(width: 10),
                    buildText('Completed tasks', kBlackColor, textSmall, FontWeight.normal, TextAlign.start, TextOverflow.clip)
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/svgs/task.svg', width: 15),
                    const SizedBox(width: 10),
                    buildText('Pending tasks', kBlackColor, textSmall, FontWeight.normal, TextAlign.start, TextOverflow.clip)
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SvgPicture.asset('assets/svgs/filter.svg'),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<TasksBloc, TasksState>(
          builder: (context, state) {
            if (state is TasksLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FetchTasksSuccess) {
              return Column(
                children: [
                  BuildTextField(
                    hint: "Search recent task",
                    controller: searchController,
                    inputType: TextInputType.text,
                    prefixIcon: const Icon(Icons.search, color: kGrey2),
                    fillColor: kWhiteColor,
                    onChange: (value) {
                      context.read<TasksBloc>().add(SearchTaskEvent(keywords: value));
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: state.tasks.isNotEmpty
                        ? ListView.separated(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        return TaskItemView(taskModel: state.tasks[index]);
                      },
                      separatorBuilder: (_, __) => const Divider(color: kGrey3),
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/svgs/tasks.svg', height: size.height * .20),
                          const SizedBox(height: 50),
                          buildText('Schedule your tasks', kBlackColor, textBold, FontWeight.w600, TextAlign.center, TextOverflow.clip),
                          buildText(
                            'Manage your task schedule easily\nand efficiently',
                            kBlackColor.withOpacity(.5),
                            textSmall,
                            FontWeight.normal,
                            TextAlign.center,
                            TextOverflow.clip,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }

            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_circle, color: Colors.blue),
        onPressed: () {
          Navigator.pushNamed(context, Pages.createNewTask);
        },
      ),
    );
  }
}
