import 'dart:ui';

import '../models/level_design.dart';
import '../utils/game_dimensions.dart';
import 'level.dart';

class Level4 implements Level {
  static double get _w => GameDimensions.blockWidth;
  static double get _h => GameDimensions.blockHeight;

  @override
  List<BlockDescriptor> build() {
    final blocks = <BlockDescriptor>[];
    // Seiten
    for (int i = 0; i < 3; i++) {
      final y = 0.15 + i * 0.07;
      blocks.add(BlockDescriptor(
          position: Offset(0.2, y),
          size: Size(_w, _h),
          type: i == 0 ? 'unbreakable' : 'normal'));
      blocks.add(BlockDescriptor(
          position: Offset(0.6, y),
          size: Size(_w, _h),
          type: i == 0 ? 'unbreakable' : 'normal'));
    }
    // Boden
    for (int i = 1; i < 4; i++) {
      blocks.add(BlockDescriptor(
          position: Offset(0.2 + i * 0.1, 0.35),
          size: Size(_w, _h),
          type: 'normal'));
    }
    return blocks;
  }
}
