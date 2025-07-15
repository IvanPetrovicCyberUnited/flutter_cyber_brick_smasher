import 'dart:ui';

import 'ball_collision_strategy.dart';

/// Collision strategy for the fireball power-up. The ball does not bounce
/// and passes through blocks while destroying them.
class FireballCollisionStrategy implements BallCollisionStrategy {
  @override
  BallCollisionResult handleCollision({
    required Offset velocity,
    required Rect ballRect,
    required Rect blockRect,
  }) {
    return BallCollisionResult(
      newVelocity: velocity,
      newPosition: ballRect.center,
      destroyBlock: true,
      passThrough: true,
    );
  }
}
