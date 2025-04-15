import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_management/components/widgets.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';
import 'package:time_management/tasks/presentation/pages/update_task_screen.dart';
import 'package:time_management/utils/font_sizes.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/util.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class TaskDetails extends StatefulWidget {
  final TaskModel taskModel;

  const TaskDetails({super.key, required this.taskModel});

  @override
  State<TaskDetails> createState() => _TaskDetails();
}

class _TaskDetails extends State<TaskDetails> {

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  String _selectedPriority = '';
  String _selectedRepeat = '';
  String _createBy= '';
  String _createById= '';
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _isCompleted = false;


  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    title.text = widget.taskModel.title;
    description.text = widget.taskModel.description;
    _selectedDay = _focusedDay;
    _rangeStart = widget.taskModel.startDateTime;
    _rangeEnd = widget.taskModel.stopDateTime;

    // Các trường mới
    _selectedPriority = widget.taskModel.priority ?? '';
    _selectedRepeat = widget.taskModel.repeat ?? '';
    _isCompleted = widget.taskModel.completed ?? false;
    _startTime = widget.taskModel.startTime!;
    _endTime = widget.taskModel.endTime!;

  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
            backgroundColor: kWhiteColor,
            appBar: const CustomAppBar(
              title: 'Task Details',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<TasksBloc, TasksState>(
                        listener: (context, state) {
                          if (state is UpdateTaskFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(state.error, kRed));
                          }
                          if (state is UpdateTaskSuccess) {
                            Navigator.pop(context);
                          }
                        }, builder: (context, state) {
                      return ListView(
                        children: [
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Dropdown for Priority
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10), // Khoảng cách giữa 2 dropdowns
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildText(
                                        'Priority',
                                        kBlackColor,
                                        textMedium,
                                        FontWeight.bold,
                                        TextAlign.start,
                                        TextOverflow.clip,
                                      ),
                                      PopupMenuButton<int>(
                                        onSelected: (value) {
                                          setState(() {
                                            _selectedPriority = value == 0 ? 'Normal' : 'Important';
                                          });
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<int>(
                                            value: 0,
                                            child: Text('Normal'),
                                          ),
                                          PopupMenuItem<int>(
                                            value: 1,
                                            child: Text('Important'),
                                          ),
                                        ],
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedPriority.isEmpty ? 'Select Priority' : _selectedPriority,
                                                style: TextStyle(fontSize: 14, color: Colors.black),
                                              ),
                                              Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Dropdown for Repeat
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10), // Khoảng cách giữa 2 dropdowns
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildText(
                                        'Repeat',
                                        kBlackColor,
                                        textMedium,
                                        FontWeight.bold,
                                        TextAlign.start,
                                        TextOverflow.clip,
                                      ),
                                      PopupMenuButton<int>(
                                        onSelected: (value) {
                                          setState(() {
                                            if(value ==0)
                                            {
                                              _selectedRepeat = 'None';
                                            }
                                            else if(value ==1)
                                            {
                                              _selectedRepeat= 'Daily';
                                            }
                                            else
                                              _selectedRepeat= 'Wekkly';
                                          });
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<int>(
                                            value: 0,
                                            child: Text('None'),
                                          ),
                                          PopupMenuItem<int>(
                                            value: 1,
                                            child: Text('Daily'),
                                          ),
                                          PopupMenuItem<int>(
                                            value: 2,
                                            child: Text('Weekly'),
                                          ),
                                        ],
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedRepeat.isEmpty ? 'Select Repeat' : _selectedRepeat,
                                                style: TextStyle(fontSize: 14, color: Colors.black),
                                              ),
                                              Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Start time: ${_startTime?.format(context) ?? 'Choose'}'),
                              ElevatedButton(
                                onPressed: () => _pickTime(isStart: true),
                                child: Text('Choose'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('EndTime: ${_endTime?.format(context) ?? 'Choose'}'),
                              ElevatedButton(
                                onPressed: () => _pickTime(isStart: false),
                                child: Text('Choose'),
                              ),
                            ],
                          ),

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
                          SizedBox(
                            width: size.width,
                            child: ElevatedButton(
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UpdateTaskScreen(taskModel: widget.taskModel),
                                      )
                                  );
                                },
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: buildText(
                                        'Edit Task',
                                        kWhiteColor,
                                        textMedium,
                                        FontWeight.w600,
                                        TextAlign.center,
                                        TextOverflow.clip),
                                )
                            ),
                          ),
                        ],
                      );
                    })))));
  }
}
