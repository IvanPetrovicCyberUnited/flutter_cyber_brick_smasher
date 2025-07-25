import 'dart:ui';

import 'ball_collision_strategy.dart';
import '../models/block.dart';

/// Collision strategy for the phaseball power-up. The ball does not bounce
/// and passes through blocks without destroying them.
class PhaseballCollisionStrategy implements BallCollisionStrategy {
  @override
  BallCollisionResult handleCollision({
    required Offset velocity,
    required Rect ballRect,
    required Rect blockRect,
    required Block block,
  }) {
    return BallCollisionResult(
      newVelocity: velocity,
      newPosition: ballRect.center,
      destroyBlock: false,
      passThrough: true,
    );
  }
}
