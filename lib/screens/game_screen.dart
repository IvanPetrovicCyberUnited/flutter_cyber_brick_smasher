import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/block.dart';
import '../models/power_up.dart';
import '../utils/constants.dart';
import '../view_models/game_view_model.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = GameViewModel(onGameOver: _showGameOverDialog)
      ..addListener(_onModelChanged);
  }

  void _onModelChanged() => setState(() {});

  void _handleKey(RawKeyEvent event) => _model.handleKeyEvent(event);

  @override
  void dispose() {
    _model.removeListener(_onModelChanged);
    _model.dispose();
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
          return RawKeyboardListener(
            focusNode: _model.focusNode,
            onKey: _handleKey,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: Text('Score: ${_model.score}',
                      style: const TextStyle(color: Colors.white)),
                ),
                for (final block in _model.blocks)
                  Positioned(
                    left: block.position.dx * width,
                    top: block.position.dy * height,
                    width: block.size.width * width,
                    height: block.size.height * height,
                    child: Image.asset(block.imagePath),
                  ),
                for (final p in _model.powerUps)
                  Positioned(
                    left: (p.position.dx - powerUpSize / 2) * width,
                    top: (p.position.dy - powerUpSize / 2) * height,
                    width: powerUpSize * width,
                    height: powerUpSize * height,
                    child: Image.asset(powerUpImage(p.type)),
                  ),
                for (final proj in _model.projectiles)
                  Positioned(
                    left: (proj.dx - projectileWidth / 2) * width,
                    top: (proj.dy - projectileHeight / 2) * height,
                    width: projectileWidth * width,
                    height: projectileHeight * height,
                    child: Image.asset('assets/images/projectile.png'),
                  ),
                Align(
                  alignment: Alignment(2 * _model.paddleX - 1, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: Image.asset(
                      _model.activePowerUps.contains(PowerUpType.gun)
                          ? 'assets/images/paddle_with_gun.png'
                          : 'assets/images/paddle.png',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(
                      2 * _model.ball.position.dx - 1,
                      2 * _model.ball.position.dy - 1),
                  child: Image.asset(_model.activePowerUps
                          .contains(PowerUpType.fireball)
                      ? 'assets/images/ball_on_fire.png'
                      : 'assets/images/ball.png'),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildMoveButton(
                      icon: Icons.arrow_left,
                      onStart: _model.startMovingLeft,
                      onStop: _model.stopMovingLeft,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildMoveButton(
                      icon: Icons.arrow_right,
                      onStart: _model.startMovingRight,
                      onStop: _model.stopMovingRight,
                    ),
                  ),
                ),
              ],
            ),
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

  void _showGameOverDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Final Score: ${_model.score}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _model.resetGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
