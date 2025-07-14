import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ball.dart';
import '../models/ball_decorator.dart';
import '../models/block.dart';
import '../models/normal_block.dart';
import '../models/unbreakable_block.dart';
import '../models/special_block.dart';
import '../models/power_up.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}





class _GameScreenState extends State<GameScreen> {
  late Timer _timer;
  Timer? _leftTimer;
  Timer? _rightTimer;
  late FocusNode _focusNode;


  late Ball _ball;

  double _paddleX = paddleInitialX; // fractional position of paddle across width
  final double _paddleSpeed = paddleSpeed;

  final List<Block> _blocks = [];
  int _score = 0;
  final List<FallingPowerUp> _powerUps = [];
  final Set<PowerUpType> _activePowerUps = {};
  final Map<PowerUpType, Timer> _timers = {};
  final double _powerUpSpeed = powerUpSpeed;
  final List<Offset> _projectiles = [];
  Timer? _gunFireTimer;
  final double _projectileSpeed = projectileSpeed;
  final Random _random = Random();


  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _ball = Ball(
      position: const Offset(ballInitialX, ballInitialY),
      velocity: const Offset(ballInitialDX, ballInitialDY),
    );
    _createBlocks();
    _timer = Timer.periodic(frameDuration, _updateBall);
  }

  void _startMovingLeft() {
    _leftTimer?.cancel();
    _leftTimer = Timer.periodic(frameDuration, (_) {
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
    _rightTimer = Timer.periodic(frameDuration, (_) {
      setState(() {
        _paddleX = (_paddleX + _paddleSpeed).clamp(0.0, 1.0);
      });
    });
  }

  void _stopMovingRight() {
    _rightTimer?.cancel();
    _rightTimer = null;
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_leftTimer == null) _startMovingLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_rightTimer == null) _startMovingRight();
      }
    } else if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _stopMovingLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _stopMovingRight();
      }
    }
  }

  void _createBlocks() {
    const int rows = blockRows;
    const int cols = blockCols;
    const double spacing = blockSpacing;
    const double topOffset = blockTopOffset;
    final double blockWidth = (1 - (cols + 1) * spacing) / cols;
    const blockImages = [
      'assets/images/block_1.png',
      'assets/images/block_2.png',
      'assets/images/block_3.png',
      'assets/images/block_4.png',
    ];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double x = spacing + c * (blockWidth + spacing);
        final double y = topOffset + r * (blockHeight + spacing);
        final image = blockImages[_random.nextInt(blockImages.length)];
        _blocks.add(NormalBlock(
          position: Offset(x, y),
          size: Size(blockWidth, blockHeight),
          image: image,
        ));
      }
    }
  }

  void _updateBall(Timer timer) {
    setState(() {
      _ball.update();
      var pos = _ball.position;
      var vel = _ball.velocity;
      if (pos.dx <= 0 || pos.dx >= 1) {
        vel = Offset(-vel.dx, vel.dy);
        pos = Offset(pos.dx.clamp(0.0, 1.0), pos.dy);
      }
      if (pos.dy <= 0) {
        vel = Offset(vel.dx, -vel.dy);
        pos = Offset(pos.dx, pos.dy.clamp(0.0, 1.0));
      }
      _ball
        ..position = pos
        ..velocity = vel;

      // simple paddle collision when moving downward
      if (_ball.velocity.dy > 0 && _ball.position.dy >= paddleY &&
          (_ball.position.dx - _paddleX).abs() <= paddleHalfWidth) {
        _ball
          ..velocity = Offset(_ball.velocity.dx, -_ball.velocity.dy)
          ..position = Offset(_ball.position.dx, paddleY);
      }

      // check for collision with blocks
      final ballRect = Rect.fromLTWH(
        _ball.position.dx - ballSize / 2,
        _ball.position.dy - ballSize / 2,
        ballSize,
        ballSize,
      );
      for (int i = 0; i < _blocks.length; i++) {
        final block = _blocks[i];
        final rect = block.rect;
        if (ballRect.overlaps(rect)) {
          if (!_activePowerUps.contains(PowerUpType.fireball)) {
            final intersection = ballRect.intersect(rect);
            var vel = _ball.velocity;
            var pos = _ball.position;
            if (intersection.height >= intersection.width) {
              vel = Offset(-vel.dx, vel.dy);
              if (vel.dx > 0) {
                pos = Offset(rect.left - ballSize / 2, pos.dy);
              } else {
                pos = Offset(rect.right + ballSize / 2, pos.dy);
              }
            } else {
              vel = Offset(vel.dx, -vel.dy);
              if (vel.dy > 0) {
                pos = Offset(pos.dx, rect.top - ballSize / 2);
              } else {
                pos = Offset(pos.dx, rect.bottom + ballSize / 2);
              }
            }
            _ball
              ..position = pos
              ..velocity = vel;
          }
          if (block.hit()) {
            _blocks.removeAt(i);
            _score += 10;
            if (_random.nextDouble() < powerUpProbability) {
              final types = PowerUpType.values;
              final randomType = types[_random.nextInt(types.length)];
              _powerUps
                  .add(FallingPowerUp(type: randomType, position: rect.center));
            }
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

      // update projectiles
      for (int i = _projectiles.length - 1; i >= 0; i--) {
        final newPos = _projectiles[i].translate(0, -_projectileSpeed);
        bool remove = false;
        final projRect = Rect.fromLTWH(
            newPos.dx - projectileWidth / 2,
            newPos.dy - projectileHeight / 2,
            projectileWidth,
            projectileHeight);
        for (int j = 0; j < _blocks.length; j++) {
          final block = _blocks[j];
          final rect = block.rect;
          if (projRect.overlaps(rect)) {
            if (block.hit()) {
              _blocks.removeAt(j);
              _score += 10;
              if (_random.nextDouble() < powerUpProbability) {
                final types = PowerUpType.values;
                final randomType = types[_random.nextInt(types.length)];
                _powerUps
                    .add(FallingPowerUp(type: randomType, position: rect.center));
              }
            }
            remove = true;
            break;
          }
        }
        if (remove || newPos.dy <= 0) {
          _projectiles.removeAt(i);
        } else {
          _projectiles[i] = newPos;
        }
      }
    });

    if (_ball.position.dy >= 1.0) {
      _ball.position = Offset(_ball.position.dx, 1.0);
      _timer.cancel();
      _leftTimer?.cancel();
      _rightTimer?.cancel();
      _gunFireTimer?.cancel();
      _showGameOverDialog();
    }
  }

  void _activatePowerUp(PowerUpType type) {
    _activePowerUps.add(type);
    _timers[type]?.cancel();
    _timers[type] = Timer(powerUpDuration, () {
      setState(() {
        _activePowerUps.remove(type);
        if (type == PowerUpType.fireball && _ball is Fireball) {
          _ball = (_ball as Fireball).ball;
        }
        if (type == PowerUpType.gun) {
          _gunFireTimer?.cancel();
          _gunFireTimer = null;
        }
      });
    });
    if (type == PowerUpType.gun) {
      _gunFireTimer?.cancel();
      _gunFireTimer =
          Timer.periodic(gunFireInterval, (_) => _fireProjectile());
    }
    if (type == PowerUpType.fireball) {
      _ball = Fireball(_ball);
    }
    setState(() {});
  }

  void _fireProjectile() {
    setState(() {
      _projectiles.add(Offset(_paddleX, projectileStartY));
    });
  }

  void _resetGame() {
    _timer.cancel();
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    _gunFireTimer?.cancel();
    _leftTimer = null;
    _rightTimer = null;
    _gunFireTimer = null;
    setState(() {
      _ball = Ball(
        position: const Offset(ballInitialX, ballInitialY),
        velocity: const Offset(ballInitialDX, ballInitialDY),
      );
      _paddleX = paddleInitialX;
      _score = 0;
      _activePowerUps.clear();
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
      _blocks.clear();
      _powerUps.clear();
      _projectiles.clear();
      _createBlocks();
    });
    _timer = Timer.periodic(frameDuration, _updateBall);
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
    _gunFireTimer?.cancel();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _focusNode.dispose();
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
            focusNode: _focusNode,
            onKey: _handleKeyEvent,
            child: Stack(
              children: [
              Positioned(
                left: 8,
                top: 8,
                child: Text('Score: $_score', style: const TextStyle(color: Colors.white)),
              ),
              for (final block in _blocks)
                Positioned(
                  left: block.position.dx * width,
                  top: block.position.dy * height,
                  width: block.size.width * width,
                  height: block.size.height * height,
                  child: Image.asset(block.imagePath),
                ),
              for (final p in _powerUps)
                Positioned(
                  left: (p.position.dx - powerUpSize / 2) * width,
                  top: (p.position.dy - powerUpSize / 2) * height,
                  width: powerUpSize * width,
                  height: powerUpSize * height,
                  child: Image.asset(powerUpImage(p.type)),
                ),
              for (final proj in _projectiles)
                Positioned(
                  left: (proj.dx - projectileWidth / 2) * width,
                  top: (proj.dy - projectileHeight / 2) * height,
                  width: projectileWidth * width,
                  height: projectileHeight * height,
                  child: Image.asset('assets/images/projectile.png'),
                ),
              Align(
                alignment: Alignment(2 * _paddleX - 1, 1),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: Image.asset(
                    _activePowerUps.contains(PowerUpType.gun)
                        ? 'assets/images/paddle_with_gun.png'
                        : 'assets/images/paddle.png',
                  ),
                ),
              ),
              Align(
                alignment:
                    Alignment(2 * _ball.position.dx - 1, 2 * _ball.position.dy - 1),
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
