import 'dart:ui';

import '../models/level_design.dart';
import '../utils/game_dimensions.dart';
import 'level.dart';

class Level3 implements Level {
  static double get _w => GameDimensions.blockWidth;
  static double get _h => GameDimensions.blockHeight;

  @override
  List<BlockDescriptor> build() {
    final blocks = <BlockDescriptor>[];
    const baseX = 0.2;
    const baseY = 0.15;
    for (int row = 0; row < 3; row++) {
      final count = 5 - row;
      final startX = baseX + row * 0.05;
      for (int col = 0; col < count; col++) {
        final x = startX + col * 0.1;
        final y = baseY + row * 0.07;
        final type = (row == 0 && col == 2) ? 'special' : 'normal';
        blocks.add(BlockDescriptor(
          position: Offset(x, y),
          size: Size(_w, _h),
          type: type,
        ));
      }
    }
    return blocks;
  }
}
