import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math.dart' show Vector2;

import '../utils/constants.dart';
import '../utils/game_dimensions.dart';
import '../utils/physics_helper.dart';

/// Strategy interface for calculating the ball's bounce when it hits the paddle.
abstract class PaddleBounceStrategy {
  /// Returns the new velocity for the ball after it hits the paddle.
  Offset calculateBounce({
    required Offset ballPosition,
    required Offset ballVelocity,
    required double paddleX,
  });
}

/// Classic arcade style bounce calculation used in games like Arkanoid.
class ClassicPaddleBounceStrategy implements PaddleBounceStrategy {
  @override
  Offset calculateBounce({
    required Offset ballPosition,
    required Offset ballVelocity,
    required double paddleX,
  }) {
    final relativeIntersectX = ballPosition.dx - paddleX;
    final normalizedRelativeIntersectionX =
        (relativeIntersectX / GameDimensions.paddleHalfWidth).clamp(-1.0, 1.0);
    final bounceAngle = normalizedRelativeIntersectionX * pi / 3; // max 60°

    final speed = ballVelocity.distance;
    final newDx = speed * sin(bounceAngle);
    final newDy = -speed * cos(bounceAngle); // always upward

    final clamped = PhysicsHelper.clampVelocity(
      Vector2(newDx, newDy),
      minBallSpeed,
      maxBallSpeed,
    );
    return Offset(clamped.x, clamped.y);
  }
}
