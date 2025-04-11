import 'dart:async';
import 'package:flutter/material.dart';
import '../components/widgets.dart';
import '../utils/color_palette.dart';
import '../utils/font_sizes.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const TasksScreen(),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeInOut));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/app_logo.png', width: 100,),
              const SizedBox(height: 20,),
              buildText('Everything Tasks', kWhiteColor, textBold,
                  FontWeight.w600, TextAlign.center, TextOverflow.clip),
              const SizedBox(
                height: 10,
              ),
              buildText('Schedule your week with ease', kWhiteColor, textTiny,
                  FontWeight.normal, TextAlign.center, TextOverflow.clip),
            ],
          )));

  }
}
