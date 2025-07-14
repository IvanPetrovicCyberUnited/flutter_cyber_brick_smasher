import 'dart:async';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer _timer;
  Timer? _leftTimer;
  Timer? _rightTimer;

  double _ballX = 0.5; // fractional position across the width
  double _ballY = 0.9; // fractional position down the screen
  double _dx = 0.01;
  final double _dy = -0.01; // move upward slightly

  double _paddleX = 0.5; // fractional position of paddle across width
  final double _paddleSpeed = 0.02;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), _updateBall);
  }

  void _startMovingLeft() {
    _leftTimer?.cancel();
    _leftTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        _paddleX = (_paddleX - _paddleSpeed).clamp(0.0, 1.0);
      });
    });
  }

  void _stopMovingLeft() {
    _leftTimer?.cancel();
    _leftTimer = null;
  }

  void _startMovingRight() {
    _rightTimer?.cancel();
    _rightTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        _paddleX = (_paddleX + _paddleSpeed).clamp(0.0, 1.0);
      });
    });
  }

  void _stopMovingRight() {
    _rightTimer?.cancel();
    _rightTimer = null;
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
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment: Alignment(2 * _paddleX - 1, 1),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Image.asset('assets/images/paddle.png'),
            ),
          ),
          Align(
            alignment: Alignment(2 * _ballX - 1, 2 * _ballY - 1),
            child: Image.asset('assets/images/ball.png'),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMoveButton(
                    icon: Icons.arrow_left,
                    onStart: _startMovingLeft,
                    onStop: _stopMovingLeft,
                  ),
                  const SizedBox(width: 24),
                  _buildMoveButton(
                    icon: Icons.arrow_right,
                    onStart: _startMovingRight,
                    onStop: _stopMovingRight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveButton({
    required IconData icon,
    required VoidCallback onStart,
    required VoidCallback onStop,
  }) {
    return GestureDetector(
      onTapDown: (_) => onStart(),
      onTapUp: (_) => onStop(),
      onTapCancel: onStop,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
