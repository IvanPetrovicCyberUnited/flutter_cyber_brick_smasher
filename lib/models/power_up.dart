import 'dart:ui';

enum PowerUpType { fireball, magnet, multiball, phaseball, gun }

String powerUpImage(PowerUpType type) {
  switch (type) {
    case PowerUpType.fireball:
      return 'assets/images/powerup_fireball.png';
    case PowerUpType.magnet:
      return 'assets/images/powerup_magnet.png';
    case PowerUpType.multiball:
      return 'assets/images/powerup_multiball.png';
    case PowerUpType.phaseball:
      return 'assets/images/powerup_phaseball.png';
    case PowerUpType.gun:
      return 'assets/images/powerup_gun.png';
  }
}

class FallingPowerUp {
  FallingPowerUp({required this.type, required this.position});
  PowerUpType type;
  Offset position;
}
