import 'dart:ui';
import '../models/level_design.dart';
import '../utils/game_dimensions.dart';

class LevelFactory {
  static double get _blockWidth => GameDimensions.blockWidth;
  static double get _blockHeight => GameDimensions.blockHeight;

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

  /// Level 1 – Einstieg mit V-Formation
  static List<BlockDescriptor> _level1() {
    return [
      BlockDescriptor(
          position: Offset(0.25, 0.25),
          size: Size(_blockWidth, _blockHeight),
          type: 'normal'),
      BlockDescriptor(
          position: Offset(0.35, 0.2),
          size: Size(_blockWidth, _blockHeight),
          type: 'normal'),
      BlockDescriptor(
          position: Offset(0.45, 0.15),
          size: Size(_blockWidth, _blockHeight),
          type: 'special'),
      BlockDescriptor(
          position: Offset(0.55, 0.2),
          size: Size(_blockWidth, _blockHeight),
          type: 'normal'),
      BlockDescriptor(
          position: Offset(0.65, 0.25),
          size: Size(_blockWidth, _blockHeight),
          type: 'normal'),
    ];
  }

  /// Level 2 – Wand mit unbreakable Block in der Mitte
  static List<BlockDescriptor> _level2() {
    final blocks = <BlockDescriptor>[];
    const startX = 0.15;
    for (int i = 0; i < 6; i++) {
      blocks.add(BlockDescriptor(
        position: Offset(startX + i * 0.1, 0.2),
        size: Size(_blockWidth, _blockHeight),
        type: i == 2 || i == 3 ? 'unbreakable' : 'normal',
      ));
    }
    return blocks;
  }

  /// Level 3 – Pyramide mit Überraschung
  static List<BlockDescriptor> _level3() {
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
            size: Size(_blockWidth, _blockHeight),
            type: type));
      }
    }
    return blocks;
  }

  /// Level 4 – U-Form mit unzerstörbaren Eckpunkten
  static List<BlockDescriptor> _level4() {
    final blocks = <BlockDescriptor>[];
    // Seiten
    for (int i = 0; i < 3; i++) {
      final y = 0.15 + i * 0.07;
      blocks.add(BlockDescriptor(
          position: Offset(0.2, y),
          size: Size(_blockWidth, _blockHeight),
          type: i == 0 ? 'unbreakable' : 'normal'));
      blocks.add(BlockDescriptor(
          position: Offset(0.6, y),
          size: Size(_blockWidth, _blockHeight),
          type: i == 0 ? 'unbreakable' : 'normal'));
    }
    // Boden
    for (int i = 1; i < 4; i++) {
      blocks.add(BlockDescriptor(
          position: Offset(0.2 + i * 0.1, 0.35),
          size: Size(_blockWidth, _blockHeight),
          type: 'normal'));
    }
    return blocks;
  }

  /// Level 5 – Zielscheibe mit special center
  static List<BlockDescriptor> _level5() {
    final blocks = <BlockDescriptor>[];
    final centerX = 0.4;
    final centerY = 0.25;

    // Inner Ring
    blocks.add(BlockDescriptor(
        position: Offset(centerX, centerY),
        size: Size(_blockWidth, _blockHeight),
        type: 'special'));

    // Middle Ring
    for (var dx in [-0.1, 0.1]) {
      blocks.add(BlockDescriptor(
          position: Offset(centerX + dx, centerY),
          size: Size(_blockWidth, _blockHeight),
          type: 'normal'));
    }
    for (var dy in [-0.07, 0.07]) {
      blocks.add(BlockDescriptor(
          position: Offset(centerX, centerY + dy),
          size: Size(_blockWidth, _blockHeight),
          type: 'normal'));
    }

    // Outer Ring
    for (var dx in [-0.2, 0.2]) {
      for (var dy in [-0.14, 0.14]) {
        final type =
            (dx.abs() == 0.2 && dy.abs() == 0.14) ? 'unbreakable' : 'normal';
        blocks.add(BlockDescriptor(
            position: Offset(centerX + dx, centerY + dy),
            size: Size(_blockWidth, _blockHeight),
            type: type));
      }
    }

    return blocks;
  }
}
