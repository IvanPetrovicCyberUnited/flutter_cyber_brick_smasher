const double ballInitialX = 0.5;
const double ballInitialY = 0.9;
const double ballInitialDX = 0.01;
const double ballInitialDY = -0.01;
const double minBallSpeed = 0.005;
const double maxBallSpeed = 0.007;

const double paddleInitialX = 0.5;
const double paddleSpeed = 0.02;
const double paddleY = 0.95;

const int blockRows = 4;
const int blockCols = 6;
const double blockSpacing = 0.02;
const double blockTopOffset = 0.1;
const double blockHeight = 0.05;

const double powerUpSpeed = 0.01;
const double projectileSpeed = 0.02;
const double powerUpProbability = 1;

const Duration frameDuration = Duration(milliseconds: 16);
const Duration powerUpDuration = Duration(seconds: 7);
const Duration gunFireInterval = Duration(milliseconds: 500);

/// How many projectile pairs the gun can fire before deactivating.
const int maxGunShots = 20;

// Sizes are provided by GameDimensions
const double powerUpSize = 0.05; // unused, kept for backward compatibility
const double projectileWidth = 0.02; // unused
const double projectileHeight = 0.04; // unused
const double projectileStartY = 0.93; // unused

