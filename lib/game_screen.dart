import 'dart:async';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer _timer;

  double _ballX = 0.5; // fractional position across the width
  double _ballY = 0.9; // fractional position down the screen
  double _dx = 0.01;
  final double _dy = -0.01; // move upward slightly

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), _updateBall);
  }

  void _updateBall(Timer timer) {
    setState(() {
      _ballX += _dx;
      _ballY += _dy;
      if (_ballX <= 0 || _ballX >= 1) {
        _dx = -_dx;
        _ballX = _ballX.clamp(0.0, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Image.asset('assets/images/paddle.png'),
            ),
          ),
          Align(
            alignment: Alignment(2 * _ballX - 1, 2 * _ballY - 1),
            child: Image.asset('assets/images/ball.png'),
          ),
        ],
      ),
    );
  }
}
