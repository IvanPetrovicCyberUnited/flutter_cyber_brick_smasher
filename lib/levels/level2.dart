import 'dart:ui';

import '../models/level_design.dart';
import '../utils/game_dimensions.dart';
import 'level.dart';

class Level2 implements Level {
  static double get _w => GameDimensions.blockWidth;
  static double get _h => GameDimensions.blockHeight;

  @override
  List<BlockDescriptor> build() {
    final blocks = <BlockDescriptor>[];
    const startX = 0.15;
    for (int i = 0; i < 6; i++) {
      blocks.add(BlockDescriptor(
        position: Offset(startX + i * 0.1, 0.2),
        size: Size(_w, _h),
        type: i == 2 || i == 3 ? 'unbreakable' : 'normal',
      ));
    }
    return blocks;
  }
}
