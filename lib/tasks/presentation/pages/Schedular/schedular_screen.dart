import 'dart:async';
import 'dart:math';

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_management/tasks/presentation/bloc/tasks_bloc.dart';

import '../../../data/local/model/task_model.dart';
import '../../../data/repository/task_repository.dart';

class Schedular extends StatefulWidget {
  const Schedular({super.key});
  @override
  _Schedular createState() => _Schedular();
}

class _Schedular extends State<Schedular> {

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late final ValueNotifier<List<TaskModel>> _selectedEvents;
  Map<DateTime, List<TaskModel>> events = {};
  late List<TaskModel> meetings = <TaskModel>[];

  // final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    loadTasks();

    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;

    // Tạm khởi tạo rỗng để tránh lỗi LateInitializationError
    _selectedEvents = ValueNotifier([]);

    // Gọi hàm async để load dữ liệu
    _initialize();
  }

  void _initialize() async {
    bool success = await loadTasks();
    if (success) {
      // Chỉ gán _selectedEvents sau khi đã có dữ liệu từ loadTasks()
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    }
  }

  Future<bool> loadTasks() async {
    try{
      final state = context.read<TasksBloc>().state;
      List<TaskModel> tasks = [];
      if(state is FetchTasksSuccess){
        tasks = state.tasks;
      }
      setState(() {
        meetings = tasks;
        events = expandEvent(meetings);
      });

      return true;
    }catch(e){
      print("loi: ${e}");
      return false;
    }
  }

  Color backgroundColor(String priority){
    Color clors = Colors.yellow;

    if(priority.endsWith("Important")){
      clors = Colors.red;
    }
    if(priority.endsWith("Normal")){
      clors = Colors.green;
    }

    return clors;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay){
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  List<TaskModel> _getEventsForDay(DateTime day) {
    // Chuẩn hóa ngày để so sánh chính xác
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);

    return events[normalizedDay] ?? [];
  }

  Map<DateTime, List<TaskModel>> expandEvent(List<TaskModel> allEvent) {
    Map<DateTime, List<TaskModel>> expandedEvents = {};

    for (var event in allEvent) {
      DateTime currentDate = DateTime(event.startDateTime!.year, event.startDateTime!.month, event.startDateTime!.day);
      DateTime endDate = DateTime(event.stopDateTime!.year, event.stopDateTime!.month, event.stopDateTime!.day);

      print("Event start date: $currentDate");  // Log check
      while (!currentDate.isAfter(endDate)) {
        // Add the current day to the events map if it's not already added
        expandedEvents.putIfAbsent(currentDate, () => []);
        expandedEvents[currentDate]!.add(event);
        currentDate = currentDate.add(Duration(days: 1)); // Move to the next day
      }
    }

    print("Expanded events: $expandedEvents");  // Log the expanded events
    return expandedEvents;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('TableCalendar - Events', style: TextStyle( fontWeight: FontWeight.bold, fontSize: 17),),
        // backgroundColor: Color(0xFF2097F5),
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: (){},
            icon: IconButton(
                onPressed: ()async {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                icon: const Icon(Icons.arrow_back)
            )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            TableCalendar(
              locale: "en_US",
              rowHeight: 50,
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                // titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Color(0xFF4038C9), // màu của nút <
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color:Color(0xFF4038C9), // màu của nút >
                ),
                formatButtonTextStyle: TextStyle(
                  color: Color(0xFF4038C9), // màu chữ
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color:
                  Colors
                      .transparent, // Giữ màu xanh cho ngày hôm nay (nếu cần)
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.white, // Màu chữ trắng
                  fontSize: 18, // Tăng cỡ chữ
                  // fontWeight: FontWeight.bold, // Chữ đậm
                ),
                todayTextStyle: TextStyle(
                  color: Colors.redAccent, // Màu chữ xanh khi là ngày hôm nay
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              availableGestures: AvailableGestures.all,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if(_calendarFormat != format){
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              eventLoader:_getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: -4, // Điều chỉnh khoảng cách với số ngày
                      child: Container(
                        width: 18, // Kích thước chấm đen
                        height: 7,
                        decoration: BoxDecoration(
                          color: Color(
                            0xFF4038C9,
                          ).withOpacity(0.5), // Màu của chấm
                          shape: BoxShape.circle,
                          // borderRadius: BorderRadius.circular(10.0)
                        ),
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                height: 0.5,
                color: Colors.black26, // Màu xanh cho đường kẻ
              ),
            ),
            Expanded(
                child: ValueListenableBuilder<List<TaskModel>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    if(value.isEmpty){
                      return Center(
                        child: Text('Không có lịch nào hết',
                          style: TextStyle(
                            color: Colors.grey, // Màu chữ xám nhẹ
                            fontSize: 14,
                          ),),
                      );
                    }else{
                      return ListView.builder(
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true, // cần có để tránh lỗi khi trong Column
                        physics: NeverScrollableScrollPhysics(), // tránh conflict cuộn
                        itemCount: value.length, // << THIẾT YẾU
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                // Thanh màu bên trái
                                Container(
                                  width: 4, // Độ rộng của thanh màu
                                  height: 50, // Chiều cao bằng với container cha
                                  color: backgroundColor( value[index].priority), // Màu sắc (có thể đổi)
                                  margin: EdgeInsets.only(right: 8), // Khoảng cách với nội dung
                                ),
                                // Nội dung của sự kiện
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),

                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${value[index].title}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4), // Khoảng cách giữa tên và giờ
                                        Text(
                                          '${value[index].startDateTime!.hour.toString().padLeft(2, '0')}:${value[index].startDateTime!.minute.toString().padLeft(2, '0')} - '
                                              '${value[index].stopDateTime!.hour.toString().padLeft(2, '0')}:${value[index].stopDateTime!.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: Colors.grey, // Màu chữ xám nhẹ
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                )
            )
          ],
        ),
      ),
    );
  }
}
