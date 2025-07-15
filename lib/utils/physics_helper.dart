import 'package:vector_math/vector_math.dart' show Vector2;

/// Helper functions for physics calculations.
class PhysicsHelper {
  /// Clamps the magnitude of [velocity] between [minSpeed] and [maxSpeed].
  /// If the vector is too slow or too fast, it is scaled to the nearest
  /// speed while preserving its direction.
  static Vector2 clampVelocity(
    Vector2 velocity,
    double minSpeed,
    double maxSpeed,
  ) {
    final speed = velocity.length;
    if (speed == 0) return velocity;
    if (speed < minSpeed) {
      return velocity.normalized() * minSpeed;
    }
    if (speed > maxSpeed) {
      return velocity.normalized() * maxSpeed;
    }
    return velocity;
  }
}
