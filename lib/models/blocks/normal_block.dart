import '../block.dart';

class NormalBlock extends Block {
  NormalBlock({required super.position, required super.size, required String image})
      : _imagePath = image,
        super(hitPoints: 1);

  final String _imagePath;

  @override
  String get imagePath => _imagePath;
}
