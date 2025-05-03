import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_management/Chat/chatbot_service.dart';
import 'package:time_management/Chat/gemini_service.dart';
import 'package:time_management/routes/pages.dart';
import 'package:time_management/tasks/data/local/data_sources/tasks_data_provider.dart';
import '../tasks/data/local/model/task_model.dart';
import '../tasks/presentation/bloc/tasks_bloc.dart';

class ChatbotMessageHandler {
  final TextEditingController controller;
  final List<Map<String, String>> messages;
  final BuildContext context;
  final GeminiService geminiService;
  final ChatBot_Service chatBotService;

  ChatbotMessageHandler({
    required this.controller,
    required this.messages,
    required this.context,
    required this.geminiService,
    required this.chatBotService,
  });

  Future<void> sendMessage(Function(bool) setLoading) async {
    final input = controller.text.trim();
    if (input.isEmpty) return;

    messages.add({'role': 'user', 'text': input});
    await _saveChatToFirestore('user', input);

    setLoading(true);
    controller.clear();

    // ✅ Xử lý đặt lịch
    if (chatBotService.isScheduleCommand(input)) {
      try {
        TaskModel? taskModel = chatBotService.extractSchedule(input);

        if (taskModel != null) {
          final taskDataProvider = TaskDataProvider();
          await taskDataProvider.createTask(taskModel);

          final confirmationMessage =
              '📅 Đã đặt lịch "${taskModel.title}" vào '
              '${taskModel.startDateTime!.day}/${taskModel.startDateTime!.month}/${taskModel.startDateTime!.year} '
              'lúc ${taskModel.startTime!.hour}:${taskModel.startTime!.minute}!';

          messages.add({'role': 'bot', 'text': confirmationMessage});
          await _saveChatToFirestore('bot', confirmationMessage);
          setLoading(false);
          return;
        } else {
          const errorMsg =
              '❌ Mình chưa hiểu. Vui lòng đặt lịch theo mẫu: "Đặt lịch [tên] lúc [giờ] ngày [ngày/tháng/năm]".';
          messages.add({'role': 'bot', 'text': errorMsg});
          await _saveChatToFirestore('bot', errorMsg);
          setLoading(false);
          return;
        }
      } catch (e) {
        print('Lỗi khi đặt lịch: $e');
      }
    }

    // ✅ Xử lý xem lịch
    if (input.toLowerCase().contains('xem') &&
        input.toLowerCase().contains('lịch')) {
      const msg = 'Oki đợi mình tí nhé!';
      messages.add({'role': 'bot', 'text': msg});
      await _saveChatToFirestore('bot', msg);
      setLoading(false);

      await Future.delayed(const Duration(milliseconds: 500), () {
        context.read<TasksBloc>().add(FetchTaskEvent());
        Navigator.pushReplacementNamed(context, Pages.schedule);
      });
      return;
    }

    // ✅ Xử lý lịch trống
    if (input.toLowerCase().contains('lịch trống') ||
        input.toLowerCase().contains('còn trống')) {
      const msg = 'Oki đợi mình tí, để mình kiểm tra nhé!';
      messages.add({'role': 'bot', 'text': msg});
      await _saveChatToFirestore('bot', msg);
      setLoading(false);

      List<String> freeSlots = await chatBotService.handleFreeSchedule();

      if (freeSlots.isEmpty) {
        const noSlots = '⛔️ Mình không tìm thấy lịch trống trong tuần này!';
        messages.add({'role': 'bot', 'text': noSlots});
        await _saveChatToFirestore('bot', noSlots);
      } else {
        final slotMsg = '🗓️ Đây là các khoảng trống bạn còn:\n' + freeSlots.join('\n');
        messages.add({'role': 'bot', 'text': slotMsg});
        await _saveChatToFirestore('bot', slotMsg);
      }

      setLoading(false);
      return;
    }

    // ✅ Mặc định: Gửi đến Gemini
    final reply = await geminiService.generateReply(input);
    messages.add({'role': 'bot', 'text': reply});
    await _saveChatToFirestore('bot', reply);

    setLoading(false);
  }

  // Ghi lịch sử chat vào Firestore
  Future<void> _saveChatToFirestore(String role, String text) async {
    await FirebaseFirestore.instance.collection('chats').add({
      'role': role,
      'title': text.length > 30 ? text.substring(0, 30) + '...' : text,
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
