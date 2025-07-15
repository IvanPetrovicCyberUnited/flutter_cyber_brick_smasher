import 'dart:math';

import '../models/level_design.dart';
import '../models/blocks/normal_block.dart';
import '../models/blocks/unbreakable_block.dart';
import '../models/blocks/special_block.dart';
import '../models/block.dart';

abstract class BlockFactory {
  Block createBlock(BlockDescriptor descriptor);
}

class DefaultBlockFactory implements BlockFactory {
  DefaultBlockFactory({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _normalImages = [
    'assets/images/block_1.png',
    'assets/images/block_2.png',
    'assets/images/block_3.png',
    'assets/images/block_4.png',
  ];

  @override
  Block createBlock(BlockDescriptor descriptor) {
    switch (descriptor.type) {
      case 'normal':
        final image = _normalImages[_random.nextInt(_normalImages.length)];
        return NormalBlock(
          position: descriptor.position,
          size: descriptor.size,
          image: image,
        );
      case 'unbreakable':
        return UnbreakableBlock(
          position: descriptor.position,
          size: descriptor.size,
        );
      case 'special':
        return SpecialBlock(
          position: descriptor.position,
          size: descriptor.size,
        );
      default:
        final image = _normalImages[_random.nextInt(_normalImages.length)];
        return NormalBlock(
          position: descriptor.position,
          size: descriptor.size,
          image: image,
        );
    }
  }
}
