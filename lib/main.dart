import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() {
  runApp(const CyberBrickSmasherApp());
}

class CyberBrickSmasherApp extends StatelessWidget {
  const CyberBrickSmasherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Brick Smasher',
      theme: ThemeData(useMaterial3: true),
      home: const StartScreen(),
    );
  }
}

