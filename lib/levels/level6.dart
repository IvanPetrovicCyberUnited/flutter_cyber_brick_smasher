import 'dart:ui';

import '../models/level_design.dart';
import '../utils/game_dimensions.dart';
import 'level.dart';

/// Level 6 – Test level with 5x5 grid, unbreakable bottom row and side columns.
class Level6 implements Level {
  static double get _w => GameDimensions.blockWidth;
  static double get _h => GameDimensions.blockHeight;

  @override
  List<BlockDescriptor> build() {
    final blocks = <BlockDescriptor>[];

    const startX = 0.25;
    const startY = 0.15;
    const spacing = 0.01;

    // 5x5 normal blocks
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final x = startX + col * (_w + spacing);
        final y = startY + row * (_h + spacing);
        blocks.add(BlockDescriptor(
          position: Offset(x, y),
          size: Size(_w, _h),
          type: 'normal',
        ));
      }
    }

    // 5 unbreakable blocks below the grid
    final unbreakableY = startY + 5 * (_h + spacing);
    for (int i = 0; i < 5; i++) {
      final x = startX + i * (_w + spacing);
      blocks.add(BlockDescriptor(
        position: Offset(x, unbreakableY),
        size: Size(_w, _h),
        type: 'unbreakable',
      ));
    }

    // 6 blocks left of the grid
    final leftX = startX - (_w + spacing);
    for (int i = 0; i < 6; i++) {
      final y = startY + i * (_h + spacing);
      blocks.add(BlockDescriptor(
        position: Offset(leftX, y),
        size: Size(_w, _h),
        type: 'normal',
      ));
    }

    // 6 blocks right of the grid
    final rightX = startX + 5 * (_w + spacing);
    for (int i = 0; i < 6; i++) {
      final y = startY + i * (_h + spacing);
      blocks.add(BlockDescriptor(
        position: Offset(rightX, y),
        size: Size(_w, _h),
        type: 'normal',
      ));
    }

    return blocks;
  }
}
