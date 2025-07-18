import '../models/level_design.dart';
import '../levels/level.dart';
import '../levels/level1.dart';
import '../levels/level2.dart';
import '../levels/level3.dart';
import '../levels/level4.dart';
import '../levels/level5.dart';
import '../levels/level6.dart';

/// Factory Method for creating level objects.
class LevelFactory {
  static Level _select(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return Level1();
      case 2:
        return Level2();
      case 3:
        return Level3();
      case 4:
        return Level4();
      case 5:
        return Level5();
      case 6:
        return Level6();
      default:
        return Level1();
    }
  }

  /// Returns the block layout for the requested level number.
  static List<BlockDescriptor> createLevel(int levelNumber) {
    return _select(levelNumber).build();
  }
}
