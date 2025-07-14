import 'dart:ui';
import 'ball.dart';

class BallDecorator extends Ball {
  BallDecorator(this._ball) : super(position: _ball.position, velocity: _ball.velocity);

  final Ball _ball;
  Ball get ball => _ball;

  @override
  Offset get position => _ball.position;
  @override
  set position(Offset value) => _ball.position = value;

  @override
  Offset get velocity => _ball.velocity;
  @override
  set velocity(Offset value) => _ball.velocity = value;

  @override
  void update() => _ball.update();

  @override
  String get imagePath => _ball.imagePath;
}

class Fireball extends BallDecorator {
  Fireball(super.ball);

  @override
  String get imagePath => 'assets/images/ball_on_fire.png';
}
