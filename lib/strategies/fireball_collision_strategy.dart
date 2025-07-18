import 'dart:ui';

import 'ball_collision_strategy.dart';
import 'default_bounce_strategy.dart';
import '../models/block.dart';
import '../models/blocks/unbreakable_block.dart';

/// Collision strategy for the fireball power-up. The ball does not bounce
/// and passes through blocks while destroying them.
class FireballCollisionStrategy implements BallCollisionStrategy {
  @override
  BallCollisionResult handleCollision({
    required Offset velocity,
    required Rect ballRect,
    required Rect blockRect,
    required Block block,
  }) {
    if (block is UnbreakableBlock) {
      return DefaultBounceStrategy().handleCollision(
        velocity: velocity,
        ballRect: ballRect,
        blockRect: blockRect,
        block: block,
      );
    }

    return BallCollisionResult(
      newVelocity: velocity,
      newPosition: ballRect.center,
      destroyBlock: true,
      passThrough: true,
    );
  }
}
