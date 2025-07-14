import 'dart:ui';

import '../models/level_design.dart';

/// Factory that generates [LevelDesign] instances for the given level number.
class LevelFactory {
  static LevelDesign createLevel(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return LevelDesign(
          levelNumber: 1,
          blocks: [
            BlockDescriptor(
              position: const Offset(0.2, 0.2),
              size: const Size(0.1, 0.05),
              type: 'normal',
            ),
            BlockDescriptor(
              position: const Offset(0.4, 0.2),
              size: const Size(0.1, 0.05),
              type: 'normal',
            ),
            BlockDescriptor(
              position: const Offset(0.3, 0.3),
              size: const Size(0.1, 0.05),
              type: 'unbreakable',
            ),
          ],
        );
      default:
        // Fall back to the first level until more are implemented.
        return createLevel(1);
    }
  }
}
