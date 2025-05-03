import 'package:flutter/material.dart';
import 'package:time_management/Chat/chatbot_service.dart';
import 'package:time_management/routes/pages.dart';
import '../proflie/theme.dart';
import 'ChatbotMessageHandler.dart';
import 'gemini_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatBot_Screen extends StatefulWidget {
  const ChatBot_Screen({super.key});

  @override
  State<ChatBot_Screen> createState() => _ChatBot_ScreenState();
}
// 'AIzaSyBbRmcJoKpe_X2U-kBX-wkIJBVX1VFFUIs';
class _ChatBot_ScreenState extends State<ChatBot_Screen> {
  final String apiKey = 'AIzaSyA833ncOoO6LzGFTPK8WwEhVdtPc5pj_6g';

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late GeminiService _gemini;
  late ChatBot_Service chatBot_Service;
  late ChatbotMessageHandler messageHandler;

  // Khai báo ScrollController để điều khiển cuộn
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _gemini = GeminiService(apiKey);
    chatBot_Service = ChatBot_Service();
    messageHandler = ChatbotMessageHandler(
      controller: _controller,
      messages: _messages,
      context: context,
      geminiService: _gemini,
      chatBotService: chatBot_Service,
    );
  }

  // Gửi tin nhắn và kiểm tra trạng thái đang tải
  void _sendMessage() {
    messageHandler.sendMessage((isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
      // Sau khi gửi xong tin nhắn, cuộn đến câu trả lời mới
      _scrollToEnd();
    });
  }

  // Cuộn đến cuối danh sách tin nhắn
  void _scrollToEnd() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        // Cuộn mượt mà đến vị trí cuối cùng
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }




@override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDark = themeProvider.isDarkMode;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '🤖 Chatbot AI',
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.teal,
          ),
        ),
      ),
      centerTitle: true,
    ),
    extendBodyBehindAppBar: true,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 100), // Vì đã có AppBar nên tăng thêm 30
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.cyan.shade400,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.pushNamed(context, Pages.chatHistory);
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                "View chat history",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUser
                            ? [Colors.teal.shade300, Colors.tealAccent.shade100]
                            : [Colors.grey.shade200, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        )
                      ],
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFE0F7FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "💬 Enter Message...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(color: Colors.cyan.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide(color: Colors.cyan.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}