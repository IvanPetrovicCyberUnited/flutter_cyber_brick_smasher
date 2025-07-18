import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/block.dart';
import '../models/power_up.dart';
import '../utils/constants.dart';
import '../utils/game_dimensions.dart';
import '../view_models/game_view_model.dart';
import '../strategies/fireball_collision_strategy.dart';
import '../strategies/phaseball_collision_strategy.dart';

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
    _model = GameViewModel()..addListener(_onModelChanged);
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _model.initialize(Size(width, height));
          });
          return RawKeyboardListener(
            focusNode: _model.focusNode,
            onKey: _handleKey,
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Score: ${_model.score}',
                          style: const TextStyle(color: Colors.white)),
                      Text('Level: ${_model.currentLevel}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
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
                    left: (p.position.dx - GameDimensions.powerUpSize / 2) * width,
                    top: (p.position.dy - GameDimensions.powerUpSize / 2) * height,
                    width: GameDimensions.powerUpSize * width,
                    height: GameDimensions.powerUpSize * height,
                    child: Image.asset(powerUpImage(p.type)),
                  ),
                for (final proj in _model.projectiles)
                  Positioned(
                    left: (proj.dx - GameDimensions.projectileWidth / 2) * width,
                    top: (proj.dy - GameDimensions.projectileHeight / 2) * height,
                    width: GameDimensions.projectileWidth * width,
                    height: GameDimensions.projectileHeight * height,
                    child: Image.asset('assets/images/projectile.png'),
                  ),
                Positioned(
                  left: (_model.paddleX - GameDimensions.paddleHalfWidth) * width,
                  top: (paddleY - GameDimensions.paddleHeight / 2) * height,
                  width: GameDimensions.paddleHalfWidth * 2 * width,
                  height: GameDimensions.paddleHeight * height,
                  child: Image.asset(
                    _model.activePowerUps.contains(PowerUpType.gun)
                        ? 'assets/images/paddle_with_gun.png'
                        : 'assets/images/paddle.png',
                  ),
                ),
                for (final ball in _model.balls)
                  Positioned(
                    left: (ball.position.dx - GameDimensions.ballSize / 2) * width,
                    top: (ball.position.dy - GameDimensions.ballSize / 2) * height,
                    width: GameDimensions.ballSize * width,
                    height: GameDimensions.ballSize * height,
                    child: Builder(
                      builder: (_) {
                        final strategy = _model.getCollisionStrategy();
                        final image = strategy is FireballCollisionStrategy
                            ? 'assets/images/ball_on_fire.png'
                            : strategy is PhaseballCollisionStrategy
                                ? 'assets/images/ball_phase.png'
                                : 'assets/images/ball.png';
                        return Image.asset(image);
                      },
                    ),
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
                if (_model.state == GameState.levelCompleted)
                  const Center(
                    child: Text(
                      'You Win',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_model.state == GameState.gameFinished)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'You Win the Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Back to Start'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_model.state == GameState.gameOver)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Game Over',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _model.resetGame,
                            child: const Text('Restart'),
                          ),
                        ],
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

}
