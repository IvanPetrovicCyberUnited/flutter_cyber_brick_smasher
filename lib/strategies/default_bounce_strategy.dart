import 'dart:ui';

import 'ball_collision_strategy.dart';

/// Default strategy for bouncing a ball off a block.
class DefaultBounceStrategy implements BallCollisionStrategy {
  @override
  BallCollisionResult handleCollision({
    required Offset velocity,
    required Rect ballRect,
    required Rect blockRect,
  }) {
    final intersection = ballRect.intersect(blockRect);
    Offset newVelocity = velocity;

    if (intersection.width >= intersection.height) {
      // Vertical collision (top/bottom)
      newVelocity = Offset(velocity.dx, -velocity.dy);
    } else {
      // Horizontal collision (left/right)
      newVelocity = Offset(-velocity.dx, velocity.dy);
    }

    return BallCollisionResult(
      newVelocity: newVelocity,
      destroyBlock: true,
      passThrough: false,
    );
  }
}
