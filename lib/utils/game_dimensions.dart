import 'dart:ui';

/// Handles conversion between pixel-based asset sizes and the logical
/// coordinate system used by the game logic (0..1 on both axes).
class GameDimensions {
  // Exact pixel dimensions of the game assets.
  static const double blockPixelWidth = 32;
  static const double blockPixelHeight = 16;
  static const double paddlePixelWidth = 64;
  static const double paddlePixelHeight = 16;
  static const double ballPixelSize = 16;
  static const double powerUpPixelSize = 24;
  static const double projectilePixelWidth = 8;
  static const double projectilePixelHeight = 16;

  static double _screenWidth = 1;
  static double _screenHeight = 1;

  /// Updates the cached screen size. Must be called once the screen
  /// dimensions are known (e.g. from [LayoutBuilder]).
  static void update(Size size) {
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  // Normalized sizes derived from the pixel dimensions.
  static double get ballSize => ballPixelSize / _screenWidth;
  static double get paddleHalfWidth => (paddlePixelWidth / _screenWidth) / 2;
  static double get paddleHeight => paddlePixelHeight / _screenHeight;
  static double get blockWidth => blockPixelWidth / _screenWidth;
  static double get blockHeight => blockPixelHeight / _screenHeight;
  static double get powerUpSize => powerUpPixelSize / _screenWidth;
  static double get projectileWidth => projectilePixelWidth / _screenWidth;
  static double get projectileHeight => projectilePixelHeight / _screenHeight;
}
