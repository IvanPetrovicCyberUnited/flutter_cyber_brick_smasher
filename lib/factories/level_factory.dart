import 'dart:ui';

import '../models/level_design.dart';

/// Factory that provides block layouts for each level.
class LevelFactory {
  static const double _blockWidth = 0.1;
  static const double _blockHeight = 0.05;

  /// Returns a list of [BlockDescriptor]s for the provided [levelNumber].
  static List<BlockDescriptor> createLevel(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return _level1();
      case 2:
        return _level2();
      case 3:
        return _level3();
      case 4:
        return _level4();
      case 5:
        return _level5();
      default:
        return _level1();
    }
  }

  static List<BlockDescriptor> _level1() {
    return [
      BlockDescriptor(
        position: const Offset(0.2, 0.2),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.4, 0.2),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.3, 0.3),
        size: const Size(_blockWidth, _blockHeight),
        type: 'unbreakable',
      ),
    ];
  }

  static List<BlockDescriptor> _level2() {
    return [
      BlockDescriptor(
        position: const Offset(0.2, 0.3),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.3, 0.25),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.4, 0.2),
        size: const Size(_blockWidth, _blockHeight),
        type: 'unbreakable',
      ),
      BlockDescriptor(
        position: const Offset(0.5, 0.15),
        size: const Size(_blockWidth, _blockHeight),
        type: 'special',
      ),
    ];
  }

  static List<BlockDescriptor> _level3() {
    return [
      BlockDescriptor(
        position: const Offset(0.35, 0.35),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.45, 0.35),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.55, 0.35),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.4, 0.3),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.5, 0.3),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ),
      BlockDescriptor(
        position: const Offset(0.45, 0.25),
        size: const Size(_blockWidth, _blockHeight),
        type: 'special',
      ),
    ];
  }

  static List<BlockDescriptor> _level4() {
    final blocks = <BlockDescriptor>[];
    const startX = 0.1;
    const stepX = 0.12;
    for (int i = 0; i < 5; i++) {
      final x = startX + i * stepX;
      blocks.add(BlockDescriptor(
        position: Offset(x, 0.2),
        size: const Size(_blockWidth, _blockHeight),
        type: i == 2 ? 'unbreakable' : 'normal',
      ));
      blocks.add(BlockDescriptor(
        position: Offset(x, 0.27),
        size: const Size(_blockWidth, _blockHeight),
        type: 'normal',
      ));
    }
    return blocks;
  }

  static List<BlockDescriptor> _level5() {
    final blocks = <BlockDescriptor>[];
    // Vertical line
    for (int i = 0; i < 5; i++) {
      blocks.add(BlockDescriptor(
        position: Offset(0.4, 0.2 + i * 0.07),
        size: const Size(_blockWidth, _blockHeight),
        type: i == 2 ? 'unbreakable' : 'normal',
      ));
    }
    // Horizontal line crossing the vertical one
    for (int i = 0; i < 5; i++) {
      final x = 0.2 + i * 0.1;
      final type = i == 2 ? 'unbreakable' : 'normal';
      blocks.add(BlockDescriptor(
        position: Offset(x, 0.34),
        size: const Size(_blockWidth, _blockHeight),
        type: type,
      ));
    }
    // Center special block
    blocks.add(BlockDescriptor(
      position: const Offset(0.4, 0.34),
      size: const Size(_blockWidth, _blockHeight),
      type: 'special',
    ));
    return blocks;
  }
}
