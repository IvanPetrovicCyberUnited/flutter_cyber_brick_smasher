import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/ball.dart';
import '../models/ball_decorator.dart';
import '../models/block.dart';
import '../models/normal_block.dart';
import '../models/power_up.dart';
import '../models/special_block.dart';
import '../models/unbreakable_block.dart';
import '../factories/level_factory.dart';
import '../utils/constants.dart';

enum GameState { playing, levelCompleted, gameFinished }

class GameViewModel extends ChangeNotifier {
  GameViewModel({this.onGameOver}) {
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    resetGame();
    _gameTimer = Timer.periodic(frameDuration, _update);
  }

  final VoidCallback? onGameOver;
  late FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;

  Timer? _gameTimer;
  Timer? _leftTimer;
  Timer? _rightTimer;
  Timer? _gunFireTimer;

  final Random _random = Random();

  late Ball ball;
  int _currentLevel = 1;
  static const int _maxLevel = 5;
  GameState _state = GameState.playing;

  int get currentLevel => _currentLevel;
  GameState get state => _state;
  double paddleX = paddleInitialX;
  int score = 0;
  final List<Block> blocks = [];
  final List<FallingPowerUp> powerUps = [];
  final Set<PowerUpType> activePowerUps = {};
  final Map<PowerUpType, Timer> _timers = {};
  final List<Offset> projectiles = [];

  /// Returns true when all breakable blocks have been destroyed.
  bool get levelComplete =>
      blocks.every((b) => b.hitPoints == -1);

  void handleKeyEvent(RawKeyEvent event) {
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

  void startMovingLeft() => _startMovingLeft();
  void stopMovingLeft() => _stopMovingLeft();
  void startMovingRight() => _startMovingRight();
  void stopMovingRight() => _stopMovingRight();

  void _startMovingLeft() {
    _leftTimer?.cancel();
    _leftTimer = Timer.periodic(frameDuration, (_) {
      paddleX = (paddleX - paddleSpeed).clamp(0.0, 1.0);
      notifyListeners();
    });
  }

  void _stopMovingLeft() {
    _leftTimer?.cancel();
    _leftTimer = null;
  }

  void _startMovingRight() {
    _rightTimer?.cancel();
    _rightTimer = Timer.periodic(frameDuration, (_) {
      paddleX = (paddleX + paddleSpeed).clamp(0.0, 1.0);
      notifyListeners();
    });
  }

  void _stopMovingRight() {
    _rightTimer?.cancel();
    _rightTimer = null;
  }

  void resetGame() {
    _gameTimer?.cancel();
    _currentLevel = 1;
    score = 0;
    _setupLevel();
    _gameTimer = Timer.periodic(frameDuration, _update);
    _focusNode.requestFocus();
    notifyListeners();
  }

  void _completeLevel() {
    _state = GameState.levelCompleted;
    _gameTimer?.cancel();
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    _gunFireTimer?.cancel();
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      if (_state != GameState.levelCompleted) return;
      if (_currentLevel >= _maxLevel) {
        _state = GameState.gameFinished;
        notifyListeners();
        return;
      }
      _currentLevel++;
      _setupLevel();
      _gameTimer = Timer.periodic(frameDuration, _update);
      notifyListeners();
    });
  }

  void _setupLevel() {
    ball = Ball(
      position: const Offset(ballInitialX, ballInitialY),
      velocity: const Offset(ballInitialDX, ballInitialDY),
    );
    paddleX = paddleInitialX;
    activePowerUps.clear();
    powerUps.clear();
    projectiles.clear();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _gunFireTimer?.cancel();
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    blocks.clear();
    _createBlocks();
    _state = GameState.playing;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
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

  void _createBlocks() {
    blocks.clear();
    const blockImages = [
      'assets/images/block_1.png',
      'assets/images/block_2.png',
      'assets/images/block_3.png',
      'assets/images/block_4.png',
    ];
    final level = LevelFactory.createLevel(_currentLevel);
    for (final descriptor in level.blocks) {
      switch (descriptor.type) {
        case 'normal':
          final image = blockImages[_random.nextInt(blockImages.length)];
          blocks.add(NormalBlock(
            position: descriptor.position,
            size: descriptor.size,
            image: image,
          ));
          break;
        case 'special':
          blocks.add(SpecialBlock(
            position: descriptor.position,
            size: descriptor.size,
          ));
          break;
        case 'unbreakable':
          blocks.add(UnbreakableBlock(
            position: descriptor.position,
            size: descriptor.size,
          ));
          break;
      }
    }
  }

  void _update(Timer timer) {
    if (_state != GameState.playing) return;
    ball.update();
    var pos = ball.position;
    var vel = ball.velocity;
    if (pos.dx <= 0 || pos.dx >= 1) {
      vel = Offset(-vel.dx, vel.dy);
      pos = Offset(pos.dx.clamp(0.0, 1.0), pos.dy);
    }
    if (pos.dy <= 0) {
      vel = Offset(vel.dx, -vel.dy);
      pos = Offset(pos.dx, pos.dy.clamp(0.0, 1.0));
    }
    ball
      ..position = pos
      ..velocity = vel;

    if (ball.velocity.dy > 0 && ball.position.dy >= paddleY &&
        (ball.position.dx - paddleX).abs() <= paddleHalfWidth) {
      ball
        ..velocity = Offset(ball.velocity.dx, -ball.velocity.dy)
        ..position = Offset(ball.position.dx, paddleY);
    }

    final ballRect = Rect.fromLTWH(
      ball.position.dx - ballSize / 2,
      ball.position.dy - ballSize / 2,
      ballSize,
      ballSize,
    );
    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      final rect = block.rect;
      if (ballRect.overlaps(rect)) {
        if (!activePowerUps.contains(PowerUpType.fireball)) {
          final intersection = ballRect.intersect(rect);
          var vel = ball.velocity;
          var pos = ball.position;
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
          ball
            ..position = pos
            ..velocity = vel;
        }
        if (block.hit()) {
          blocks.removeAt(i);
          score += 10;
          if (_random.nextDouble() < powerUpProbability) {
            final types = PowerUpType.values;
            final randomType = types[_random.nextInt(types.length)];
            powerUps.add(FallingPowerUp(type: randomType, position: rect.center));
          }
        }
        break;
      }
    }

    for (int i = powerUps.length - 1; i >= 0; i--) {
      final p = powerUps[i];
      final newPos = p.position.translate(0, powerUpSpeed);
      if (newPos.dy >= 1.0) {
        powerUps.removeAt(i);
        continue;
      }
      if (newPos.dy >= paddleY && (newPos.dx - paddleX).abs() <= paddleHalfWidth) {
        powerUps.removeAt(i);
        _activatePowerUp(p.type);
        continue;
      }
      p.position = newPos;
    }

    for (int i = projectiles.length - 1; i >= 0; i--) {
      final newPos = projectiles[i].translate(0, -projectileSpeed);
      bool remove = false;
      final projRect = Rect.fromLTWH(
        newPos.dx - projectileWidth / 2,
        newPos.dy - projectileHeight / 2,
        projectileWidth,
        projectileHeight,
      );
      for (int j = 0; j < blocks.length; j++) {
        final block = blocks[j];
        final rect = block.rect;
        if (projRect.overlaps(rect)) {
          if (block.hit()) {
            blocks.removeAt(j);
            score += 10;
            if (_random.nextDouble() < powerUpProbability) {
              final types = PowerUpType.values;
              final randomType = types[_random.nextInt(types.length)];
              powerUps.add(FallingPowerUp(type: randomType, position: rect.center));
            }
          }
          remove = true;
          break;
        }
      }
      if (remove || newPos.dy <= 0) {
        projectiles.removeAt(i);
      } else {
        projectiles[i] = newPos;
      }
    }

    if (ball.position.dy >= 1.0) {
      ball.position = Offset(ball.position.dx, 1.0);
      _gameTimer?.cancel();
      _leftTimer?.cancel();
      _rightTimer?.cancel();
      _gunFireTimer?.cancel();
      onGameOver?.call();
    }

    if (levelComplete) {
      _completeLevel();
      return;
    }
    notifyListeners();
  }

  void _activatePowerUp(PowerUpType type) {
    activePowerUps.add(type);
    _timers[type]?.cancel();
    _timers[type] = Timer(powerUpDuration, () {
      activePowerUps.remove(type);
      if (type == PowerUpType.fireball && ball is Fireball) {
        ball = (ball as Fireball).ball;
      }
      if (type == PowerUpType.gun) {
        _gunFireTimer?.cancel();
        _gunFireTimer = null;
      }
      notifyListeners();
    });
    if (type == PowerUpType.gun) {
      _gunFireTimer?.cancel();
      _gunFireTimer = Timer.periodic(gunFireInterval, (_) => _fireProjectile());
    }
    if (type == PowerUpType.fireball) {
      ball = Fireball(ball);
    }
    notifyListeners();
  }

  void _fireProjectile() {
    projectiles.add(const Offset(paddleInitialX, projectileStartY));
    notifyListeners();
  }
}
