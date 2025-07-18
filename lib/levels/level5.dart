import 'dart:ui';

import '../models/level_design.dart';
import '../utils/game_dimensions.dart';
import 'level.dart';

class Level5 implements Level {
  static double get _w => GameDimensions.blockWidth;
  static double get _h => GameDimensions.blockHeight;

  @override
  List<BlockDescriptor> build() {
    final blocks = <BlockDescriptor>[];
    final centerX = 0.4;
    final centerY = 0.25;

    // Inner Ring
    blocks.add(BlockDescriptor(
        position: Offset(centerX, centerY),
        size: Size(_w, _h),
        type: 'special'));

    // Middle Ring
    for (var dx in [-0.1, 0.1]) {
      blocks.add(BlockDescriptor(
          position: Offset(centerX + dx, centerY),
          size: Size(_w, _h),
          type: 'normal'));
    }
    for (var dy in [-0.07, 0.07]) {
      blocks.add(BlockDescriptor(
          position: Offset(centerX, centerY + dy),
          size: Size(_w, _h),
          type: 'normal'));
    }

    // Outer Ring
    for (var dx in [-0.2, 0.2]) {
      for (var dy in [-0.14, 0.14]) {
        final type =
            (dx.abs() == 0.2 && dy.abs() == 0.14) ? 'unbreakable' : 'normal';
        blocks.add(BlockDescriptor(
            position: Offset(centerX + dx, centerY + dy),
            size: Size(_w, _h),
            type: type));
      }
    }

    return blocks;
  }
}
