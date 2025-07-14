import 'dart:ui';

abstract class Block {
  Block({required this.position, required this.size, required this.hitPoints});

  Offset position;
  Size size;
  int hitPoints;

  Rect get rect => Rect.fromLTWH(position.dx, position.dy, size.width, size.height);

  String get imagePath;

  bool hit() {
    if (hitPoints > 0) {
      hitPoints--;
    }
    return hitPoints <= 0;
  }
}
