import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}


enum PowerUpType { fireball, magnet, multiball, phaseball, gun }

String _powerUpImage(PowerUpType type) {
  switch (type) {
    case PowerUpType.fireball:
      return 'assets/images/powerup_fireball.png';
    case PowerUpType.magnet:
      return 'assets/images/powerup_magnet.png';
    case PowerUpType.multiball:
      return 'assets/images/powerup_multiball.png';
    case PowerUpType.phaseball:
      return 'assets/images/powerup_phaseball.png';
    case PowerUpType.gun:
      return 'assets/images/powerup_gun.png';
  }
}

class _FallingPowerUp {
  _FallingPowerUp({required this.type, required this.position});
  PowerUpType type;
  Offset position;
}


class _GameScreenState extends State<GameScreen> {
  late Timer _timer;
  Timer? _leftTimer;
  Timer? _rightTimer;

  double _ballX = 0.5; // fractional position across the width
  double _ballY = 0.9; // fractional position down the screen
  double _dx = 0.01;
  double _dy = -0.01; // moving direction vertically

  double _paddleX = 0.5; // fractional position of paddle across width
  final double _paddleSpeed = 0.02;

  final List<Rect> _blocks = [];
  int _score = 0;
  final List<_FallingPowerUp> _powerUps = [];
  final Set<PowerUpType> _activePowerUps = {};
  final Map<PowerUpType, Timer> _timers = {};
  final double _powerUpSpeed = 0.01;

  @override
  void initState() {
    super.initState();
    _createBlocks();
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

  void _createBlocks() {
    const int rows = 4;
    const int cols = 6;
    const double spacing = 0.02;
    const double topOffset = 0.1;
    const double blockHeight = 0.05;
    final double blockWidth = (1 - (cols + 1) * spacing) / cols;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double x = spacing + c * (blockWidth + spacing);
        final double y = topOffset + r * (blockHeight + spacing);
        _blocks.add(Rect.fromLTWH(x, y, blockWidth, blockHeight));
      }
    }
  }

  void _updateBall(Timer timer) {
    setState(() {
      _ballX += _dx;
      _ballY += _dy;
      if (_ballX <= 0 || _ballX >= 1) {
        _dx = -_dx;
        _ballX = _ballX.clamp(0.0, 1.0);
      }
      if (_ballY <= 0) {
        _dy = -_dy;
        _ballY = _ballY.clamp(0.0, 1.0);
      }

      // simple paddle collision when moving downward
      const double paddleY = 0.95; // approximate fractional vertical position
      const double paddleHalfWidth = 0.1; // half the paddle width as fraction
      if (_dy > 0 && _ballY >= paddleY &&
          (_ballX - _paddleX).abs() <= paddleHalfWidth) {
        _dy = -_dy;
        _ballY = paddleY;
      }

      // check for collision with blocks
      const double ballSize = 0.04;
      final ballRect = Rect.fromLTWH(
        _ballX - ballSize / 2,
        _ballY - ballSize / 2,
        ballSize,
        ballSize,
      );
      for (int i = 0; i < _blocks.length; i++) {
        final block = _blocks[i];
        if (ballRect.overlaps(block)) {
          if (!_activePowerUps.contains(PowerUpType.fireball)) {
            final intersection = ballRect.intersect(block);
            if (intersection.height >= intersection.width) {
              _dx = -_dx;
              if (_dx > 0) {
                _ballX = block.left - ballSize / 2;
              } else {
                _ballX = block.right + ballSize / 2;
              }
            } else {
              _dy = -_dy;
              if (_dy > 0) {
                _ballY = block.top - ballSize / 2;
              } else {
                _ballY = block.bottom + ballSize / 2;
              }
            }
          }
          _blocks.removeAt(i);
          _score += 10;
          if (Random().nextDouble() < 0.25) {
            final types = PowerUpType.values;
            final randomType = types[Random().nextInt(types.length)];
            _powerUps.add(_FallingPowerUp(type: randomType, position: block.center));
          }
          break;
        }
      }

      // update power-ups
      for (int i = _powerUps.length - 1; i >= 0; i--) {
        final p = _powerUps[i];
        final newPos = p.position.translate(0, _powerUpSpeed);
        if (newPos.dy >= 1.0) {
          _powerUps.removeAt(i);
          continue;
        }
        if (newPos.dy >= paddleY && (newPos.dx - _paddleX).abs() <= paddleHalfWidth) {
          _powerUps.removeAt(i);
          _activatePowerUp(p.type);
          continue;
        }
        p.position = newPos;
      }
    });

    if (_ballY >= 1.0) {
      _ballY = 1.0;
      _timer.cancel();
      _leftTimer?.cancel();
      _rightTimer?.cancel();
      _showGameOverDialog();
    }
  }

  void _activatePowerUp(PowerUpType type) {
    _activePowerUps.add(type);
    _timers[type]?.cancel();
    _timers[type] = Timer(const Duration(seconds: 7), () {
      setState(() {
        _activePowerUps.remove(type);
      });
    });
    setState(() {});
  }

  void _resetGame() {
    _timer.cancel();
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    _leftTimer = null;
    _rightTimer = null;
    setState(() {
      _ballX = 0.5;
      _ballY = 0.9;
      _dx = 0.01;
      _dy = -0.01;
      _paddleX = 0.5;
      _score = 0;
      _activePowerUps.clear();
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
      _blocks.clear();
      _powerUps.clear();
      _createBlocks();
    });
    _timer = Timer.periodic(const Duration(milliseconds: 16), _updateBall);
  }

  void _showGameOverDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Final Score: $_score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              Positioned(
                left: 8,
                top: 8,
                child: Text('Score: $_score', style: const TextStyle(color: Colors.white)),
              ),
              for (final block in _blocks)
                Positioned(
                  left: block.left * width,
                  top: block.top * height,
                  width: block.width * width,
                  height: block.height * height,
                  child: Image.asset('assets/images/block_1.png'),
                ),
              for (final p in _powerUps)
                Positioned(
                  left: (p.position.dx - 0.025) * width,
                  top: (p.position.dy - 0.025) * height,
                  width: 0.05 * width,
                  height: 0.05 * height,
                  child: Image.asset(_powerUpImage(p.type)),
                ),
              Align(
                alignment: Alignment(2 * _paddleX - 1, 1),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: Image.asset('assets/images/paddle.png'),
                ),
              ),
              Align(
                alignment: Alignment(2 * _ballX - 1, 2 * _ballY - 1),
                child: Image.asset(

                  _activePowerUps.contains(PowerUpType.fireball)
                      ? 'assets/images/ball_on_fire.png'
                      : 'assets/images/ball.png',
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildMoveButton(
                    icon: Icons.arrow_left,
                    onStart: _startMovingLeft,
                    onStop: _stopMovingLeft,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildMoveButton(
                    icon: Icons.arrow_right,
                    onStart: _startMovingRight,
                    onStop: _stopMovingRight,
                  ),
                ),
              ),
            ],
          );
        },
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
