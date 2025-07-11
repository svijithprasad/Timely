import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptySearchPlaceholder extends StatelessWidget {
  const EmptySearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              "assets/animations/error.json", // use same Lottie
              frameRate: FrameRate(60),
              height: 250,
              repeat: true,
            ),
            const SizedBox(height: 20),
            const Text(
              "Search for your tasks here..",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try using different keywords or check for typos",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
