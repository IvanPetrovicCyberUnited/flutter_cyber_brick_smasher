import 'dart:ui';

import '../models/level_design.dart';
import '../utils/game_dimensions.dart';
import 'level.dart';

class Level1 implements Level {
  static double get _w => GameDimensions.blockWidth;
  static double get _h => GameDimensions.blockHeight;

  @override
  List<BlockDescriptor> build() {
    return [
      BlockDescriptor(position: Offset(0.25, 0.25), size: Size(_w, _h), type: 'normal'),
      BlockDescriptor(position: Offset(0.35, 0.2), size: Size(_w, _h), type: 'normal'),
      BlockDescriptor(position: Offset(0.45, 0.15), size: Size(_w, _h), type: 'special'),
      BlockDescriptor(position: Offset(0.55, 0.2), size: Size(_w, _h), type: 'normal'),
      BlockDescriptor(position: Offset(0.65, 0.25), size: Size(_w, _h), type: 'normal'),
    ];
  }
}
