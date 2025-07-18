import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart';

import '../models/ball.dart';
import '../models/ball_decorator.dart';
import '../managers/ball_manager.dart';
import '../models/block.dart';
import '../models/blocks/normal_block.dart';
import '../models/power_up.dart';
import '../models/blocks/special_block.dart';
import '../models/blocks/unbreakable_block.dart';
import '../factories/level_factory.dart';
import '../factories/block_factory.dart';
import '../utils/constants.dart';
import '../utils/game_dimensions.dart';
import '../utils/physics_helper.dart';
import '../strategies/ball_collision_strategy.dart';
import '../strategies/default_bounce_strategy.dart';
import '../strategies/paddle_bounce_strategy.dart';
import '../strategies/fireball_collision_strategy.dart';
import '../strategies/phaseball_collision_strategy.dart';

enum GameState { playing, levelCompleted, gameOver, gameFinished }

class GameViewModel extends ChangeNotifier {
  GameViewModel({
    BlockFactory? blockFactory,
    PaddleBounceStrategy? paddleBounceStrategy,
  }) {
    _blockFactory = blockFactory ?? DefaultBlockFactory(random: _random);
    _focusNode = FocusNode();
    this.paddleBounceStrategy =
        paddleBounceStrategy ?? ClassicPaddleBounceStrategy();
  }

  bool _initialized = false;

  /// Must be called once the screen size is known to set up sizes and start the game.
  void initialize(Size size) {
    if (_initialized) return;
    GameDimensions.update(size);
    resetGame();
    _gameTimer = Timer.periodic(frameDuration, _update);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _initialized = true;
  }

  late FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;

  Timer? _gameTimer;
  bool _isMovingLeft = false;
  bool _isMovingRight = false;
  double _paddleVelocity = 0.0;
  Timer? _gunFireTimer;
  int _gunShotsRemaining = 0;
  Timer? _magnetPowerUpTimer;
  bool _magnetActive = false;
  Timer? _levelTransitionTimer;
  final Map<Ball, DateTime> _heldBalls = {};

  final Random _random = Random();
  late final BlockFactory _blockFactory;

  /// Strategy used to resolve collisions between the ball and blocks.
  late BallCollisionStrategy ballCollisionStrategy;

  /// Strategy used to compute the ball's reflection when hitting the paddle.
  late PaddleBounceStrategy paddleBounceStrategy;

  /// Returns the currently active collision strategy based on [activePowerUps].
  BallCollisionStrategy getCollisionStrategy() =>
      _getCollisionStrategy(activePowerUps);

  /// Manages all active balls in the game.
  final BallManager ballManager = BallManager();
  List<Ball> get balls => ballManager.balls;
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
  bool get levelComplete => blocks.every((b) => b.hitPoints == -1);

  void handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _startMovingLeft();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _startMovingRight();
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

  void _startMovingLeft() => _isMovingLeft = true;

  void _stopMovingLeft() {
    _isMovingLeft = false;
  }

  void _startMovingRight() => _isMovingRight = true;

  void _stopMovingRight() {
    _isMovingRight = false;
  }

  void resetGame() {
    _gameTimer?.cancel();
    _levelTransitionTimer?.cancel();
    _currentLevel = 1;
    score = 0;
    _isMovingLeft = false;
    _isMovingRight = false;
    _paddleVelocity = 0;
    _setupLevel();
    _state = GameState.playing;
    _gameTimer = Timer.periodic(frameDuration, _update);
    _focusNode.requestFocus();
    notifyListeners();
  }

  void _completeLevel() {
    _state = GameState.levelCompleted;
    _gameTimer?.cancel();
    _gunFireTimer?.cancel();
    _magnetPowerUpTimer?.cancel();
    _levelTransitionTimer?.cancel();
    _isMovingLeft = false;
    _isMovingRight = false;
    _paddleVelocity = 0;
    _heldBalls.clear();
    notifyListeners();
    _levelTransitionTimer?.cancel();
    _levelTransitionTimer = Timer(const Duration(seconds: 2), () {
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

  void _gameOver() {
    _state = GameState.gameOver;
    _gameTimer?.cancel();
    _gunFireTimer?.cancel();
    _magnetPowerUpTimer?.cancel();
    _levelTransitionTimer?.cancel();
    _isMovingLeft = false;
    _isMovingRight = false;
    _paddleVelocity = 0;
    _heldBalls.clear();
    notifyListeners();
  }

  void _setupLevel() {
    ballManager.balls.clear();
    ballManager.addBall(
      Ball(
        position: const Offset(ballInitialX, ballInitialY),
        velocity: const Offset(ballInitialDX, ballInitialDY),
      ),
    );
    ballCollisionStrategy = DefaultBounceStrategy();
    paddleX = paddleInitialX;
    activePowerUps.clear();
    powerUps.clear();
    projectiles.clear();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _isMovingLeft = false;
    _isMovingRight = false;
    _paddleVelocity = 0;
    _gunFireTimer?.cancel();
    _gunShotsRemaining = 0;
    _magnetPowerUpTimer?.cancel();
    _magnetActive = false;
    _heldBalls.clear();
    blocks.clear();
    _createBlocks();
    _state = GameState.playing;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _gunFireTimer?.cancel();
    _magnetPowerUpTimer?.cancel();
    _levelTransitionTimer?.cancel();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _heldBalls.clear();
    _focusNode.dispose();
    super.dispose();
  }

  void _createBlocks() {
    blocks.clear();
    final descriptors = LevelFactory.createLevel(_currentLevel);
    for (final descriptor in descriptors) {
      blocks.add(_blockFactory.createBlock(descriptor));
    }
  }

  void _update(Timer timer) {
    if (_state != GameState.playing) return;

    // Handle paddle movement with acceleration and deceleration.
    if (_isMovingLeft && !_isMovingRight) {
      _paddleVelocity = (_paddleVelocity - paddleAcceleration)
          .clamp(-paddleSpeed, 0.0);
    } else if (_isMovingRight && !_isMovingLeft) {
      _paddleVelocity = (_paddleVelocity + paddleAcceleration)
          .clamp(0.0, paddleSpeed);
    } else {

      if (_paddleVelocity > 0) {
        _paddleVelocity = (_paddleVelocity - paddleAcceleration)
            .clamp(0.0, paddleSpeed);
      } else if (_paddleVelocity < 0) {
        _paddleVelocity = (_paddleVelocity + paddleAcceleration)
            .clamp(-paddleSpeed, 0.0);
      }
    }
    paddleX = (paddleX + _paddleVelocity).clamp(0.0, 1.0);

    final strategy = _getCollisionStrategy(activePowerUps);

    final now = DateTime.now();

    ballManager.forEach((ball) {
      final holdStart = _heldBalls[ball];
      if (holdStart != null) {
        if (now.difference(holdStart) < magnetHoldDuration) {
          final holdY = paddleY -
              GameDimensions.paddleHeight / 2 -
              GameDimensions.ballSize / 2;
          ball
            ..position = Offset(paddleX, holdY)
            ..velocity = Offset.zero;
          return;
        } else {
          _heldBalls.remove(ball);
          ball.velocity = const Offset(0, -minBallSpeed);
        }
      }

      final clampedStart = PhysicsHelper.clampVelocity(
        Vector2(ball.velocity.dx, ball.velocity.dy),
        minBallSpeed,
        maxBallSpeed,
      );
      ball.velocity = Offset(clampedStart.x, clampedStart.y);

      ball.update();
      var pos = ball.position;
      var vel = ball.velocity;

      // Wände
      if (pos.dx <= 0 || pos.dx >= 1) {
        vel = Offset(-vel.dx, vel.dy);
        pos = Offset(pos.dx.clamp(0.0, 1.0), pos.dy);
      }
      // Oben
      if (pos.dy <= 0) {
        vel = Offset(vel.dx, -vel.dy);
        pos = Offset(pos.dx, pos.dy.clamp(0.0, 1.0));
      }

      final clampedWall = PhysicsHelper.clampVelocity(
        Vector2(vel.dx, vel.dy),
        minBallSpeed,
        maxBallSpeed,
      );
      ball
        ..position = pos
        ..velocity = Offset(clampedWall.x, clampedWall.y);

      // 🧠 Paddle-Kollision mit realistischer Reflexion oder Magnet
      if (ball.velocity.dy > 0 &&
          ball.position.dy >= paddleY &&
          (ball.position.dx - paddleX).abs() <=
              GameDimensions.paddleHalfWidth) {
        if (_magnetActive && !_heldBalls.containsKey(ball)) {
          _heldBalls[ball] = now;
          final holdY = paddleY -
              GameDimensions.paddleHeight / 2 -
              GameDimensions.ballSize / 2;
          ball
            ..position = Offset(paddleX, holdY)
            ..velocity = Offset.zero;
          return;
        }

        final newVel = paddleBounceStrategy.calculateBounce(
          ballPosition: ball.position,
          ballVelocity: ball.velocity,
          paddleX: paddleX,
        );
        ball
          ..velocity = newVel
          ..position = Offset(ball.position.dx, paddleY);
      }

      // 🎯 Ball-zu-Block-Kollision
      final ballRect = Rect.fromLTWH(
        ball.position.dx - GameDimensions.ballSize / 2,
        ball.position.dy - GameDimensions.ballSize / 2,
        GameDimensions.ballSize,
        GameDimensions.ballSize,
      );

      for (int i = 0; i < blocks.length; i++) {
        final block = blocks[i];
        final rect = block.rect;

        if (ballRect.overlaps(rect)) {
          final result = strategy.handleCollision(
            velocity: ball.velocity,
            ballRect: ballRect,
            blockRect: rect,
            block: block,
          );

          var vel = result.newVelocity;
          var pos = result.newPosition;
          final clampedBlock = PhysicsHelper.clampVelocity(
            Vector2(vel.dx, vel.dy),
            minBallSpeed,
            maxBallSpeed,
          );
          vel = Offset(clampedBlock.x, clampedBlock.y);

          // The strategy already resolves overlap

          ball
            ..position = pos
            ..velocity = vel;

          if (result.destroyBlock && block.hit()) {
            blocks.removeAt(i);
            score += 10;

            if (_random.nextDouble() < powerUpProbability) {
              final types = PowerUpType.values;
              final randomType = types[_random.nextInt(types.length)];
              powerUps.add(FallingPowerUp(
                type: randomType,
                position: rect.center,
              ));
            }
          }

          if (!result.passThrough) {
            break;
          }
        }
      }
    });

    // ⬇️ Powerups
    for (int i = powerUps.length - 1; i >= 0; i--) {
      final p = powerUps[i];
      final newPos = p.position.translate(0, powerUpSpeed);

      if (newPos.dy >= 1.0) {
        powerUps.removeAt(i);
        continue;
      }

      if (newPos.dy >= paddleY &&
          (newPos.dx - paddleX).abs() <= GameDimensions.paddleHalfWidth) {
        powerUps.removeAt(i);
        _activatePowerUp(p.type);
        continue;
      }

      p.position = newPos;
    }

    // 🔫 Projektile
    for (int i = projectiles.length - 1; i >= 0; i--) {
      final newPos = projectiles[i].translate(0, -projectileSpeed);
      bool remove = false;
      final projRect = Rect.fromLTWH(
        newPos.dx - GameDimensions.projectileWidth / 2,
        newPos.dy - GameDimensions.projectileHeight / 2,
        GameDimensions.projectileWidth,
        GameDimensions.projectileHeight,
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
              powerUps.add(FallingPowerUp(
                type: randomType,
                position: rect.center,
              ));
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

    // 🧱 Unten raus
    ballManager.removeOffscreen();
    _heldBalls.removeWhere((ball, _) => !balls.contains(ball));

    if (ballManager.isEmpty) {
      _gameOver();
    }

    // 🎉 Level komplett
    if (levelComplete) {
      _completeLevel();
      return;
    }

    notifyListeners();
  }

  void _activatePowerUp(PowerUpType type) {
    if (type == PowerUpType.multiball) {
      _spawnMultiballs();
      return;
    }

    activePowerUps.add(type);
    if (type == PowerUpType.magnet) {
      _magnetPowerUpTimer?.cancel();
      _magnetPowerUpTimer =
          Timer(magnetPowerUpDuration, () => _deactivatePowerUp(type));
    } else {
      _timers[type]?.cancel();
      _timers[type] = Timer(powerUpDuration, () => _deactivatePowerUp(type));
    }

    if (type == PowerUpType.magnet) {
      _magnetActive = true;
    }
    if (type == PowerUpType.gun) {
      _gunShotsRemaining = maxGunShots;
      _gunFireTimer?.cancel();
      _gunFireTimer =
          Timer.periodic(gunFireInterval, (_) => _fireProjectile());
    }
    if (type == PowerUpType.fireball) {
      ballCollisionStrategy = FireballCollisionStrategy();
    }
    if (type == PowerUpType.phaseball) {
      ballCollisionStrategy = PhaseballCollisionStrategy();
    }
    notifyListeners();
  }

  void _deactivatePowerUp(PowerUpType type) {
    activePowerUps.remove(type);
    if (type == PowerUpType.magnet) {
      _magnetActive = false;
      _magnetPowerUpTimer?.cancel();
      _magnetPowerUpTimer = null;
    } else {
      _timers[type]?.cancel();
      _timers.remove(type);

    }
    if (type == PowerUpType.fireball) {
      ballCollisionStrategy = DefaultBounceStrategy();
    }
    if (type == PowerUpType.phaseball) {
      ballCollisionStrategy = DefaultBounceStrategy();
    }
    if (type == PowerUpType.gun) {
      _gunFireTimer?.cancel();
      _gunFireTimer = null;
      _gunShotsRemaining = 0;
    }

    notifyListeners();
  }

  BallCollisionStrategy _getCollisionStrategy(Set<PowerUpType> activePowerUps) {
    if (activePowerUps.contains(PowerUpType.phaseball)) {
      return PhaseballCollisionStrategy();
    }
    if (activePowerUps.contains(PowerUpType.fireball)) {
      return FireballCollisionStrategy();
    }
    return DefaultBounceStrategy();
  }

  /// Spawns additional balls when the multiball power-up is collected.
  void _spawnMultiballs() {
    if (balls.isEmpty) return;
    final base = balls.first;
    const spreads = [
      Offset(-0.01, -0.02),
      Offset(0.01, -0.02),
      Offset(-0.02, -0.01),
      Offset(0.02, -0.01),
    ];
    for (final offset in spreads) {
      final newBall = Ball(position: base.position, velocity: base.velocity + offset);
      ballManager.addBall(newBall);
    }
    notifyListeners();
  }

  void _fireProjectile() {
    if (_gunShotsRemaining <= 0) {
      _deactivatePowerUp(PowerUpType.gun);
      return;
    }

    final startY = paddleY -
        GameDimensions.paddleHeight / 2 -
        GameDimensions.projectileHeight / 2;
    final leftX = paddleX - GameDimensions.paddleHalfWidth;
    final rightX = paddleX + GameDimensions.paddleHalfWidth;

    projectiles.add(Offset(leftX, startY));
    projectiles.add(Offset(rightX, startY));
    _gunShotsRemaining--;
    notifyListeners();
  }
}
