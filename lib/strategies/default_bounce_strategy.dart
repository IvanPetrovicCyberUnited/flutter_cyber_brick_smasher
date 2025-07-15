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
    final previousRect = ballRect.translate(-velocity.dx, -velocity.dy);
    final intersection = ballRect.intersect(blockRect);
    var newVelocity = velocity;
    var newRect = ballRect;

    final cameFromLeft =
        previousRect.right <= blockRect.left && ballRect.right >= blockRect.left;
    final cameFromRight =
        previousRect.left >= blockRect.right && ballRect.left <= blockRect.right;
    final cameFromTop =
        previousRect.bottom <= blockRect.top && ballRect.bottom >= blockRect.top;
    final cameFromBottom =
        previousRect.top >= blockRect.bottom && ballRect.top <= blockRect.bottom;

    if (cameFromLeft) {
      newVelocity = Offset(-newVelocity.dx, newVelocity.dy);
      newRect = newRect.translate(-intersection.width, 0);
    } else if (cameFromRight) {
      newVelocity = Offset(-newVelocity.dx, newVelocity.dy);
      newRect = newRect.translate(intersection.width, 0);
    }

    if (cameFromTop) {
      newVelocity = Offset(newVelocity.dx, -newVelocity.dy);
      newRect = newRect.translate(0, -intersection.height);
    } else if (cameFromBottom) {
      newVelocity = Offset(newVelocity.dx, -newVelocity.dy);
      newRect = newRect.translate(0, intersection.height);
    }

    return BallCollisionResult(
      newVelocity: newVelocity,
      newPosition: newRect.center,
      destroyBlock: true,
      passThrough: false,
    );
  }
}
