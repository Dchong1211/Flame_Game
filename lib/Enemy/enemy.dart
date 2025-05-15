// import 'package:final_project/knight.dart';
// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
//
// import '../player.dart';
//
// enum EnemyState { idle, walk, attack, hurt, death }
//
// class Enemy extends SpriteAnimationGroupComponent<EnemyState>
//     with HasGameReference<Game2D>, CollisionCallbacks {
//   Enemy({required this.player, required Vector2 position})
//       : super(position: position);
//
//   final Player player;
//
//   late final SpriteAnimation idleAnimation;
//   late final SpriteAnimation walkAnimation;
//   late final SpriteAnimation attackAnimation;
//   late final SpriteAnimation hurtAnimation;
//   late final SpriteAnimation deathAnimation;
//
//   final double stepTime = 0.1;
//   double speed = 50;
//   double health = 100;
//   bool isDead = false;
//   bool isAttacking = false;
//   int lastDirection = 1;
//
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//
//     anchor = Anchor.center;
//     scale = Vector2.all(0.5);
//
//     idleAnimation = _loadAnimation('Enemies/_Idle.png', 4);
//     walkAnimation = _loadAnimation('Enemies/_Walk.png', 6);
//     attackAnimation = _loadAnimation('Enemies/_Attack.png', 4, loop: false);
//     hurtAnimation = _loadAnimation('Enemies/_Hurt.png', 2, loop: false);
//     deathAnimation = _loadAnimation('Enemies/_Death.png', 6, loop: false);
//
//     animations = {
//       EnemyState.idle: idleAnimation,
//       EnemyState.walk: walkAnimation,
//       EnemyState.attack: attackAnimation,
//       EnemyState.hurt: hurtAnimation,
//       EnemyState.death: deathAnimation,
//     };
//
//     current = EnemyState.idle;
//   }
//
//   SpriteAnimation _loadAnimation(String path, int frameCount,
//       {bool loop = true}) {
//     return SpriteAnimation.fromFrameData(
//       game.images.fromCache(path),
//       SpriteAnimationData.sequenced(
//         amount: frameCount,
//         stepTime: stepTime,
//         textureSize: Vector2(64, 64),
//         loop: loop,
//       ),
//     );
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//
//     if (isDead) return;
//
//     final distance = (player.position - position).length;
//
//     if (distance < 100) {
//       if (!isAttacking) {
//         attack();
//       }
//     } else if (distance < 200) {
//       moveTowardPlayer(dt);
//     } else {
//       current = EnemyState.idle;
//     }
//   }
//
//   void moveTowardPlayer(double dt) {
//     current = EnemyState.walk;
//
//     final direction = (player.position - position).normalized();
//     position += direction * speed * dt;
//
//     // Lật hướng
//     if (direction.x < 0) {
//       scale.x = -0.5;
//       lastDirection = -1;
//     } else {
//       scale.x = 0.5;
//       lastDirection = 1;
//     }
//   }
//
//   void attack() {
//     isAttacking = true;
//     current = EnemyState.attack;
//
//     animationTicker?.onComplete = () {
//       isAttacking = false;
//       animationTicker?.onComplete = null;
//     };
//   }
//
//   void takeDamage(double damage) {
//     if (isDead) return;
//
//     health -= damage;
//     current = EnemyState.hurt;
//
//     animationTicker?.onComplete = () {
//       if (health <= 0) {
//         die();
//       } else {
//         current = EnemyState.idle;
//       }
//     };
//   }
//
//   void die() {
//     isDead = true;
//     current = EnemyState.death;
//     animationTicker?.onComplete = () => removeFromParent();
//   }
// }
