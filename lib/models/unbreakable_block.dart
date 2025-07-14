import 'block.dart';

class UnbreakableBlock extends Block {
  UnbreakableBlock({required super.position, required super.size})
      : super(hitPoints: -1);

  @override
  bool hit() => false;

  @override
  String get imagePath => 'assets/images/block_5.png';
}
