import 'dart:ui';

/// Represents the result of a ball-block collision.
class BallCollisionResult {
  final Offset newVelocity;
  final bool destroyBlock;
  final bool passThrough;

  const BallCollisionResult({
    required this.newVelocity,
    required this.destroyBlock,
    required this.passThrough,
  });
}

/// Strategy interface for handling ball-block collisions.
abstract class BallCollisionStrategy {
  BallCollisionResult handleCollision({
    required Offset velocity,
    required Rect ballRect,
    required Rect blockRect,
  });
}
