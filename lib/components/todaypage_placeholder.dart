import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TodaypagePlaceholder extends StatelessWidget {
  const TodaypagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Lottie.asset(
            "assets/animations/todoy.json",
            frameRate: FrameRate(60),
          ),
        ),
        Text(
          "No Tasks For Today",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        Text(
          "Add some tasks to make your day productive",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
