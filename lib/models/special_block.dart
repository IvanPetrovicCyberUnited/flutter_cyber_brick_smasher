import 'block.dart';

class SpecialBlock extends Block {
  SpecialBlock({required super.position, required super.size}) : super(hitPoints: 2);

  @override
  String get imagePath => hitPoints == 2
      ? 'assets/images/special_block_intact.png'
      : 'assets/images/special_block_damaged.png';
}
