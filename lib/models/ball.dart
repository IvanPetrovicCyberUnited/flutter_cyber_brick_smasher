import 'dart:ui';

class Ball {
  Ball({required this.position, required this.velocity});

  Offset position;
  Offset velocity;

  void update() {
    position = position.translate(velocity.dx, velocity.dy);
  }

  String get imagePath => 'assets/images/ball.png';
}
