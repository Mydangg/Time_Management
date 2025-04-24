import 'package:flutter/material.dart';

class ScreeenNotificationWeb extends StatefulWidget {
  final OverlayEntry overlayEntry;

  const ScreeenNotificationWeb({required this.overlayEntry});

  @override
  State<ScreeenNotificationWeb> createState() => _ScreeenNotificationWebState();
}

class _ScreeenNotificationWebState extends State<ScreeenNotificationWeb> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.notifications, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "⏰ Đã đến lúc thực hiện nhiệm vụ!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  widget.overlayEntry.remove(); // Close the overlay when the button is pressed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
