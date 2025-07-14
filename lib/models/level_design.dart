import 'dart:ui';

/// Describes a block within a level layout.
/// [type] must be one of 'normal', 'unbreakable', or 'special'.
class BlockDescriptor {
  BlockDescriptor({
    required this.position,
    required this.size,
    required this.type,
  });

  Offset position;
  Size size;
  String type;
}

/// Represents a complete level design composed of multiple [BlockDescriptor]s.
class LevelDesign {
  LevelDesign({required this.levelNumber, required this.blocks});

  final int levelNumber;
  final List<BlockDescriptor> blocks;
}
