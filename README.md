# flutter_cyber_brick_smasher

Cyber Brick Smasher is a simple Flutter game that follows a basic
Model-View-ViewModel (MVVM) approach. The game logic lives inside the
`GameViewModel` while `GameScreen` renders the state. This separation
makes it easier to test and extend the game mechanics.

The physics interactions use the **Strategy pattern**. Different
strategies handle block collisions and how the ball bounces off the
paddle. By encapsulating these behaviors, new effects like fireball or
alternative paddle mechanics can be added without changing the game
loop. For instance, the fireball collision logic delegates to the
default bounce strategy when hitting unbreakable blocks, showing how
strategies can be composed for flexible behavior.

The magnet power-up temporarily overrides these strategies by holding
the ball on the paddle. A simple timer releases the ball after four
seconds so the existing collision strategies continue to work without
modification.

When the multiball power-up is collected, a **Composite pattern**
manages several `Ball` instances at once. The `BallManager` treats the
collection of balls like a single entity so the game loop can update,
render, and remove them uniformly.

Keyboard input now uses frame-based flags instead of timers. Paddle
movement relies on velocity and acceleration so that holding or
releasing the arrow keys smoothly ramps the paddle speed up or down with
immediate response.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
