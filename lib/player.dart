import 'dart:async';
import 'package:final_project/game2d.dart';
import 'package:final_project/levels/check_collisions.dart';
import 'package:final_project/levels/collisions.dart';
import 'package:final_project/levels/hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum PlayerState{idle, run, jump, fall}


class Player extends SpriteAnimationGroupComponent with HasGameReference<Game2D>{
  Player({required Vector2 position}) : super(position: position);
  late final SpriteAnimation idle;
  late final SpriteAnimation run;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  final double stepTime = 0.07;

  double horizontal = 0;
  double speed = 90;

  final double gravity = 9.8;
  final double jumpForce = 260;
  final double terminalVelocity = 300;
  bool isOnGround = false;

  int jumpCount = 0;
  final int maxJumps = 2;

  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox = PlayerHitbox(offsetX: 15, offsetY: 6, width: 18, height: 42);

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  @override
  Future<void> onLoad() async {
    loadAllAnimation();

    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    scale = Vector2.all(1.5);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        updatePlayerState();
        updatePlayerMovement(fixedDeltaTime);
        checkHorizontalCollisions();
        applyGravity(fixedDeltaTime);
        checkVerticalCollisions();
      }

      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  SpriteAnimation loadAnimation(String path, int frame){
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: frame,
        stepTime: stepTime,
        textureSize: Vector2(32,32),
      ),
    );
  }

  void loadAllAnimation() {
    idle = loadAnimation('Character/_Idle.png', 10);
    run = loadAnimation('Character/_Run.png', 10);
    jumpAnimation = loadAnimation('Character/_Jump.png', 3);
    fallAnimation = loadAnimation('Character/_Fall.png', 3);

    animations = {
      PlayerState.idle: idle,
      PlayerState.run: run,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation
    };
    current = PlayerState.idle;
  }

  void updatePlayerMovement(double dt) {
    velocity.x = horizontal * speed;
    position.x += velocity.x * dt;
  }

  void updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if(velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    }
    else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }

    if(velocity.y < 0){
      playerState = PlayerState.jump;
    } else if (velocity.y > 0) {
      playerState = PlayerState.fall;
    } else if(velocity.x != 0){
      playerState = PlayerState.run;
    } else {
      playerState = PlayerState.idle;
    }

    current = playerState;
  }

  void checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }
  void applyGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpForce, terminalVelocity);
    position.y += velocity.y * dt;
  }

  void checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            jumpCount = 0;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            jumpCount = 0;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
          }
        }
      }
    }
  }

  void jump() {
    if (jumpCount < maxJumps) {
      velocity.y = -jumpForce;
      isOnGround = false;
      jumpCount++;
    }
  }
}