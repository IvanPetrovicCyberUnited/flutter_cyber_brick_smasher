import '../models/ball.dart';

/// Manages a collection of balls using the composite pattern.
/// The game can treat the manager like a single entity that
/// updates and removes balls uniformly.
class BallManager {
  final List<Ball> _balls = [];

  List<Ball> get balls => _balls;

  /// Adds a ball to the manager.
  void addBall(Ball ball) => _balls.add(ball);

  /// Iterates over all balls and calls [action] on each.
  void forEach(void Function(Ball ball) action) {
    for (final b in List<Ball>.from(_balls)) {
      action(b);
    }
  }

  /// Removes balls that have moved off the bottom of the screen.
  void removeOffscreen() {
    for (int i = _balls.length - 1; i >= 0; i--) {
      if (_balls[i].position.dy >= 1.0) {
        _balls.removeAt(i);
      }
    }
  }

  bool get isEmpty => _balls.isEmpty;
}

