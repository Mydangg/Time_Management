import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/util.dart';
import '../../data/local/model/task_model.dart';
import '../bloc/tasks_bloc.dart';

class SchedularItemView extends StatefulWidget {
  final List<TaskModel> task;
  const SchedularItemView({super.key, required this.task});

  @override
  State<SchedularItemView> createState() => _SchedularItemView();
}

class _SchedularItemView extends State<SchedularItemView> {

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
    try {
      setState(() {
        meetings = widget.task;
        events = expandEvent(meetings);
      });

      return true;
    } catch (e) {
      print("loi: ${e}");
      return false;
    }
  }

  Color backgroundColor(String priority) {
    Color clors = Colors.yellow;

    if (priority.endsWith("Important")) {
      clors = Colors.red;
    }
    if (priority.endsWith("Normal")) {
      clors = Colors.green;
    }

    return clors;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
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
      DateTime currentDate = DateTime(
        event.startDateTime!.year,
        event.startDateTime!.month,
        event.startDateTime!.day,
      );

      DateTime endDate =
      event.stopDateTime != null
          ? DateTime(
        event.stopDateTime!.year,
        event.stopDateTime!.month,
        event.stopDateTime!.day,
      )
          : currentDate.add(
        Duration(days: 365),
      ); // nếu không có ngày kết thúc thì giới hạn 1 năm

      String repeat = event.repeat ?? "None";

      if (event.repeat == 'Daily') {
        for (int i = 0; i <= 360; i++) {
          // Add for the next 7 days
          final eventDate = currentDate.add(
            Duration(days: i),
          ); // Daily recurrence
          expandedEvents.putIfAbsent(eventDate, () => []);
          expandedEvents[eventDate]!.add(event);
        }
      }else{
        while (!currentDate.isAfter(endDate)) {
          final eventDate = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
          );

          expandedEvents.putIfAbsent(eventDate, () => []);
          expandedEvents[eventDate]!.add(event);

          //   // Check for weekly events and add them for the next 4 weeks
          if (event.repeat == 'Weekly') {
            for (int i = 1; i <= 200; i++) {
              // Add for the next 4 weeks
              final eventDate = currentDate.add(
                Duration(days: i * 7),
              ); // Weekly recurrence
              expandedEvents.putIfAbsent(eventDate, () => []);
              expandedEvents[eventDate]!.add(event);
            }
          }

          currentDate = currentDate.add(
            Duration(days: 1),
          ); // Move to the next day
        }
      }
    }

    return expandedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          locale: "en_US",
          rowHeight: 50,
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            // titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 18),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Color(0xFF4038C9), // màu của nút <
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Color(0xFF4038C9), // màu của nút >
            ),
            formatButtonTextStyle: TextStyle(
              color: Color(0xFF4038C9), // màu chữ
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color:
              Colors
                  .transparent,
              // Giữ màu xanh cho ngày hôm nay (nếu cần)
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: Colors.white, // Màu chữ trắng
              fontSize: 18, // Tăng cỡ chữ
              // fontWeight: FontWeight.bold, // Chữ đậm
            ),
            todayTextStyle: TextStyle(
              color:
              Colors
                  .redAccent, // Màu chữ xanh khi là ngày hôm nay
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
            if (_calendarFormat != format) {
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
          eventLoader: _getEventsForDay,
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
              if (value.isEmpty) {
                return Center(
                  child: Text(
                    'Không có lịch nào hết',
                    style: TextStyle(
                      color: Colors.grey, // Màu chữ xám nhẹ
                      fontSize: 14,
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  shrinkWrap:
                  true,
                  // cần có để tránh lỗi khi trong Column
                  physics:
                  NeverScrollableScrollPhysics(),
                  // tránh conflict cuộn
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          // Thanh màu bên trái
                          Container(
                            width: 4,
                            height: 50,
                            color: backgroundColor(
                              value[index].priority,
                            ),
                            margin: EdgeInsets.only(right: 8),
                          ),
                          // Nội dung của sự kiện (có thể bấm vào)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                final result = Navigator.pushNamed(
                                  context,
                                  Pages.taskDetail,
                                  arguments: value[index],
                                );
                              },
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
                                    SizedBox(height: 4),
                                    Text(
                                      '${value[index].startTime!.hour
                                          .toString().padLeft(
                                          2, '0')}:${value[index]
                                          .startTime!.minute
                                          .toString()
                                          .padLeft(2, '0')} - '
                                          '${value[index].endTime!
                                          .hour.toString().padLeft(
                                          2, '0')}:${value[index]
                                          .endTime!.minute.toString()
                                          .padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        ),
      ],
    );
  }
}
