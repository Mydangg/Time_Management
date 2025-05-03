import 'package:flutter/material.dart';
import 'package:time_management/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:time_management/tasks/data/local/model/task_model.dart';

class ChatBot_Service{
  bool isScheduleCommand(String input) {
    final lower = input.toLowerCase();

    final hasKeyword = lower.contains('đặt lịch') ||
        lower.contains('lên lịch') ||
        lower.contains('gặp') ||
        lower.contains('làm');

    final hasDayOfWeek = RegExp(r'(thứ ?[2-7]|chủ nhật|cn)', caseSensitive: false).hasMatch(lower);
    final hasFullDate = RegExp(r'\b\d{1,2}([/-])\d{1,2}\b').hasMatch(lower) ||
        RegExp(r'\b\d{1,2} ?(tháng|thg) ?\d{1,2}\b').hasMatch(lower);

    return hasKeyword && (hasDayOfWeek || hasFullDate);
  }

  TaskModel? extractSchedule(String input) {
    final lower = input.toLowerCase();

    // Regex để tìm tiêu đề sự kiện, ngày, và giờ
    final RegExp eventRegex = RegExp(r'(?<=(đặt lịch| lên lịch | đặt lịch cho| tạo cuộc hẹn)\s)(.*?)(?=\s*(lúc| vào))', caseSensitive: false);
    final RegExp dayRegex = RegExp(r'ngày ?(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})', caseSensitive: false);
    final RegExp timeRegex = RegExp(r'(\d{1,2})(h| giờ)(\d{1,2})?', caseSensitive: false);

    final eventMatch = eventRegex.firstMatch(lower);
    final dayMatch = dayRegex.firstMatch(lower);
    final timeMatches = timeRegex.allMatches(lower).toList();

    TimeOfDay? timeOfDay;

    // Nếu có giờ thì parse giờ thành TimeOfDay
    if (timeMatches.isNotEmpty) {
      String? hourString = timeMatches[0].group(1);
      String? minuteString = timeMatches[0].group(3); // Lấy phút (có thể null)

      if (hourString != null) {
        int hour = int.parse(hourString);
        int minute = minuteString != null ? int.parse(minuteString) : 00;

        timeOfDay = TimeOfDay(hour: hour, minute: minute);
      }
    }

    // Nếu có ngày thì parse ngày thành DateTime
    String dateString = '';
    if (dayMatch != null) {
      dateString = dayMatch.group(1)!.replaceAll(RegExp(r'[/-]'), '-').trim();

      List<String> dateParts = dateString.split('-');
      if (dateParts.length == 3) {
        String day = dateParts[0].padLeft(2, '0'); // Thêm số 0 nếu ngày chỉ có 1 chữ số
        String month = dateParts[1].padLeft(2, '0'); // Thêm số 0 nếu tháng chỉ có 1 chữ số
        String year = dateParts[2];

        dateString = '$year-$month-$day'; // Định dạng lại ngày theo chuẩn yyyy-MM-dd
      }
    }

    DateTime startDateTime = DateTime.parse(dateString);

    // Kiểm tra nếu tất cả dữ liệu cần thiết đã được tìm thấy
    if (eventMatch != null && dayMatch != null && timeOfDay != null) {

      final String taskId = DateTime.now()
          .millisecondsSinceEpoch
          .toString();

      TaskModel taskModel = TaskModel(
        id: taskId,
        title: eventMatch.group(0)!.trim(),
        description: "Chưa có nội dung",
        priority: "Normal",
        repeat: "None",
        createBy: "",
        createById: "",
        startDateTime: startDateTime,
        stopDateTime: startDateTime,
        startTime: timeOfDay,
        endTime: timeOfDay,
      );

      return taskModel;
    }

    // Trả về null nếu không tìm thấy dữ liệu hợp lệ
    return null;
  }
  Future<List<String>> handleFreeSchedule() async {
    TaskDataProvider taskDataProvider = TaskDataProvider();
    List<TaskModel> tasks = await taskDataProvider.getTasks(); // lấy toàn bộ task lưu local

    Map<DateTime, List<TaskModel>> groupedTasks = {};

    // Gom nhóm task theo từng ngày
    for (var task in tasks) {
      if (task.startDateTime != null) {
        DateTime day = DateTime(task.startDateTime!.year, task.startDateTime!.month, task.startDateTime!.day);
        if (!groupedTasks.containsKey(day)) {
          groupedTasks[day] = [];
        }
        groupedTasks[day]!.add(task);
      }
    }

    List<String> slots = [];
    DateTime today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime day = today.add(Duration(days: i));
      DateTime dayStart = DateTime(day.year, day.month, day.day, 0, 0);
      DateTime dayEnd = DateTime(day.year, day.month, day.day, 23, 59);

      List<TaskModel> tasksInDay = groupedTasks[DateTime(day.year, day.month, day.day)] ?? [];

      if (tasksInDay.isEmpty) {
        slots.add("${day.day}/${day.month}: Cả ngày rảnh 🌟");
      } else {
        tasksInDay.sort((a, b) {
          if (a.startDateTime == null && b.startDateTime == null) return 0;
          if (a.startDateTime == null) return 1;
          if (b.startDateTime == null) return -1;
          return a.startDateTime!.compareTo(b.startDateTime!);
        });

        DateTime lastEndTime = dayStart;

        for (var task in tasksInDay) {
          // if (task.startDateTime!.isAfter(lastEndTime)) {
          //   slots.add("${day.day}/${day.month}: Rảnh từ ${_formatTime(lastEndTime)} đến ${_formatTime(task.startDateTime!)}");
          // }

          DateTime taskEndTime = task.startDateTime!.add(Duration(hours: 1)); // Giả sử task kéo dài 1 tiếng
          slots.add("${day.day}/${day.month}: Bận '${task.title ?? 'Công việc'}' từ ${task.startTime!.hour}:${task.startTime!.minute} đến ${task.endTime!.hour}:${task.endTime!.minute}");

          lastEndTime = taskEndTime;
        }
      }
    }

    return slots;
  }

// Hàm phụ định dạng giờ đẹp đẹp
  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

}

