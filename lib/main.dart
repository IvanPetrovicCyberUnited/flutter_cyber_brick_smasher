import 'package:flutter/material.dart';
import 'game_screen.dart';

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

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cyber Brick Smasher')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GameScreen()),
            );
          },
          child: const Text('Start Game'),
        ),
      ),
    );
  }
}
