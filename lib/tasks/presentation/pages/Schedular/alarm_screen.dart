import 'dart:async'; // Import Timer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final FlutterTts flutterTts = FlutterTts(); // Khởi tạo FlutterTts

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  Timer? _timer; // Khởi tạo timer để lặp lại giọng nói

  @override
  void initState() {
    super.initState();
    // Phát giọng nói khi màn hình được tạo
    WakelockPlus.enable();

    _speakAlarmMessage();
    // Bắt đầu timer để phát lại giọng nói mỗi phút
    _startTimer();
  }

  // Hàm phát giọng nói thông báo
  Future<void> _speakAlarmMessage() async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setSpeechRate(0.5); // Tốc độ nói chậm
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak("⏰ Đã tới giờ học Flutter rồi anh!");
  }

  // Hàm dừng giọng nói
  Future<void> _stopSpeaking() async {
    await flutterTts.stop();
  }

  // Hàm bắt đầu lặp lại giọng nói mỗi phút
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Phát lại giọng nói sau mỗi 1 phút
      _speakAlarmMessage();
    });
  }

  // Hàm hủy timer khi người dùng nhấn bỏ qua
  void _cancelTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    // Hủy timer khi màn hình được đóng
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '⏰ Báo thức!',
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Dừng giọng nói và hủy timer khi nhấn "Bỏ qua"
                _stopSpeaking();
                _cancelTimer();
                Navigator.of(context).pop();
              },
              child: const Text('Bỏ qua'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
