import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_management/components/widgets.dart';
import 'package:time_management/services/firestore.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';
import 'package:time_management/utils/font_sizes.dart';
import 'package:time_management/utils/util.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final FirestoreService firestoreService = FirestoreService();

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  List<bool> _priorityChecked = [false, false];
  String _selectedPriority = '';
  String _createBy= '';
  String _createById= '';



  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;


  // Bien luu gi tri muc do

  @override
  void initState() {
    _selectedDay = _focusedDay;
    super.initState();
  }

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
            backgroundColor: kWhiteColor,
            appBar: const CustomAppBar(
              title: 'Create New Task',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<TasksBloc, TasksState>(
                        listener: (context, state) {
                      if (state is AddTaskFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            getSnackBar(state.error, kRed));
                      }
                      if (state is AddTasksSuccess) {
                        Navigator.pop(context);
                      }
                    }, builder: (context, state) {
                      return ListView(
                        children: [
                          TableCalendar(
                            calendarFormat: _calendarFormat,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                              CalendarFormat.week: 'Week',
                            },
                            rangeSelectionMode: RangeSelectionMode.toggledOn,
                            focusedDay: _focusedDay,
                            firstDay: DateTime.utc(2023, 1, 1),
                            lastDay: DateTime.utc(2030, 1, 1),
                            onPageChanged: (focusDay) {
                              _focusedDay = focusDay;
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            rangeStartDay: _rangeStart,
                            rangeEndDay: _rangeEnd,
                            onFormatChanged: (format) {
                              if (_calendarFormat != format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              }
                            },
                            onRangeSelected: _onRangeSelected,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(.1),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: buildText(
                                _rangeStart != null && _rangeEnd != null
                                    ? 'Task starting at ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                                    : 'Select a date range',
                                Colors.blue,
                                textSmall,
                                FontWeight.w400,
                                TextAlign.start,
                                TextOverflow.clip),
                          ),
                          const SizedBox(height: 20),
                          buildText(
                              'Title',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildTextField(
                              hint: "Task Title",
                              controller: title,
                              inputType: TextInputType.text,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(
                            height: 20,
                          ),
                          buildText(
                              'Priority',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip
                          ),
                          Column(
                            children: [
                              CheckboxListTile(
                                title: Text('Normal'),
                                value: _priorityChecked[0],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _priorityChecked[0] = value!;
                                    if (_priorityChecked[0]) {
                                      _selectedPriority = 'Normal';
                                      _priorityChecked[1] = false; // Uncheck 'Important'
                                    }
                                  });
                                },
                              ),
                              CheckboxListTile(
                                title: Text('Important'),
                                value: _priorityChecked[1],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _priorityChecked[1] = value!;
                                    if (_priorityChecked[1]) {
                                      _selectedPriority = 'Important';
                                      _priorityChecked[0] = false; // Uncheck 'Normal'
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          buildText(
                              'Description',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 10,
                          ),
                          BuildTextField(
                              hint: "Task Description",
                              controller: description,
                              inputType: TextInputType.multiline,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              kWhiteColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Cancel',
                                          kBlackColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.blue),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      final String taskId = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      var taskModel = TaskModel(
                                          id: taskId,
                                          title: title.text,
                                          description: description.text,
                                          priority: _selectedPriority,
                                          createBy: _createBy,
                                          createById: _createById,
                                          startDateTime: _rangeStart,
                                          stopDateTime: _rangeEnd);
                                      context.read<TasksBloc>().add(
                                          AddNewTaskEvent(
                                              taskModel: taskModel));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Save',
                                          kWhiteColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                            ],
                          )
                        ],
                      );
                    })))));
  }
}
