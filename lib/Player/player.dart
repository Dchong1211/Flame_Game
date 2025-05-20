import 'dart:async';
import 'package:final_project/Enemy/enemy.dart';
import 'package:final_project/Items/checkpoint.dart';
import 'package:final_project/Items/coins.dart';
import 'package:final_project/Items/heart.dart';
import 'package:final_project/Player/attack_hitbox.dart';
import 'package:final_project/Traps/shuriken.dart';
import 'package:final_project/knight.dart';
import 'package:final_project/Collisions/check_collisions.dart';
import 'package:final_project/Collisions/collisions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../Collisions/hitbox.dart';

enum PlayerState { idle, run, jump, fall, attack1, attack2, attack3, hit, death }

class Player extends SpriteAnimationGroupComponent
    with HasGameReference<Knight>, KeyboardHandler, CollisionCallbacks {
  Player({required Vector2 position}) : super(position: position);
  late AttackHitbox attackHitbox;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation attack1Animation;
  late final SpriteAnimation attack2Animation;
  late final SpriteAnimation attack3Animation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation deathAnimation;

  final double stepTime = 0.07;
  late final RectangleHitbox customHitbox;

  double horizontal = 0;
  double speed = 70;

  final double gravity = 9.8;
  final double jumpForce = 230;
  final double terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  bool reachedCheckpoint = false;
  int jumpCount = 0;
  final int maxJumps = 2;
  int lastDirection = 1;
  int heartCount = 3;

  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox = PlayerHitbox(offsetX: 20, offsetY: 26, width: 24, height: 38);
  Vector2 startingPosition = Vector2.zero();

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  bool gotHit = false;

  int currentCombo = 0;
  int queuedCombo = 0;
  bool isAttacking = false;

  final double invincibleDuration = 1;
  double invincibleTimer = 0.0;


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    loadAllAnimation();
    startingPosition = Vector2(position.x, position.y);
    anchor = Anchor.center;
    debugMode = true;
    attackHitbox = AttackHitbox(
      size: Vector2(40, 30),
      position: Vector2(20, 10),
    )..anchor = Anchor.topLeft;
    customHitbox = RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),

    );
    add(customHitbox);

    scale = Vector2.all(0.5);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      horizontal = -1;
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      horizontal = 1;
    }
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        attack();
      }
      if (event.logicalKey == LogicalKeyboardKey.space) {
        jump();
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        updatePlayerState();
        updatePlayerMovement(fixedDeltaTime);
        checkHorizontalCollisions();
      }

      applyGravity(fixedDeltaTime);
      checkVerticalCollisions();

      accumulatedTime -= fixedDeltaTime;
    }

    if (invincibleTimer > 0) {
      invincibleTimer -= dt;
      if (invincibleTimer <= 0) {
        gotHit = false;
      }
    }

    super.update(dt);
  }


  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Coins) other.collidedWithPlayer();
      if (other is Heart) other.collidedWithPlayer();
      if (other is Shuriken) hurt();
      if (other is Checkpoint) _reachedCheckpoint();
      if (other is Enemy && !isAttacking) {
        collidedWithEnemy();
      }

    }
    super.onCollisionStart(intersectionPoints, other);

  }

  SpriteAnimation loadAnimation(String path, int frame, {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(path),
      SpriteAnimationData.sequenced(
        amount: frame,
        stepTime: stepTime,
        textureSize: Vector2(64, 64),
        loop: loop,
      ),
    );
  }

  void loadAllAnimation() {
    idleAnimation = loadAnimation('Character/_Idle.png', 7);
    runAnimation = loadAnimation('Character/_Run.png', 8);
    jumpAnimation = loadAnimation('Character/_Jump.png', 3);
    fallAnimation = loadAnimation('Character/_Fall.png', 3);
    attack1Animation = loadAnimation('Character/_Attack1.png', 6, loop: false);
    attack2Animation = loadAnimation('Character/_Attack2.png', 5, loop: false);
    attack3Animation = loadAnimation('Character/_Attack3.png', 6, loop: false);
    hitAnimation = loadAnimation('Character/_Hit.png', 4, loop: false);
    deathAnimation = loadAnimation('Character/_Death.png', 12, loop: false);

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.attack1: attack1Animation,
      PlayerState.attack2: attack2Animation,
      PlayerState.attack3: attack3Animation,
      PlayerState.hit: hitAnimation,
      PlayerState.death: deathAnimation
    };
    current = PlayerState.idle;
  }

  void updatePlayerMovement(double dt) {
    if (isAttacking || gotHit) {
      velocity.x = 0;
      return;
    }
    velocity.x = horizontal * speed;
    position.x += velocity.x * dt;

    if (horizontal < 0 && lastDirection != -1) {
      scale.x = -0.5;
      lastDirection = -1;
    } else if (horizontal > 0 && lastDirection != 1) {
      scale.x = 0.5;
      lastDirection = 1;
    }
  }

  void updatePlayerState() {
    if (isAttacking || gotHit) return;

    PlayerState playerState = PlayerState.idle;

    if (velocity.y < 0) {
      playerState = PlayerState.jump;
    } else if (velocity.y > 0) {
      playerState = PlayerState.fall;
    } else if (velocity.x != 0) {
      playerState = PlayerState.run;
    }

    current = playerState;
  }

  void checkHorizontalCollisions() {
    final playerRect = customHitbox.toAbsoluteRect();

    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        final blockRect = Rect.fromLTWH(block.x, block.y, block.width, block.height);

        if (playerRect.overlaps(blockRect)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.width / 2 + 5;
            break;
          } else if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width / 2 - 5;
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
      if (checkCollision(this, block)) {
        final playerBottom = position.y + hitbox.height / 4 + hitbox.offsetY / 4;

        if (block.isPlatform) {
          final platformTop = block.y;
          if (velocity.y > 0 && playerBottom <= platformTop + 7) {
            velocity.y = 0;
            position.y = platformTop - hitbox.height / 4 - hitbox.offsetY / 4;
            isOnGround = true;
            jumpCount = 0;
            break;
          }
        } else {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - (hitbox.height / 2 + hitbox.offsetY / 2) / 2;
            isOnGround = true;
            jumpCount = 0;
            break;
          } else if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height + hitbox.height / 2 - hitbox.offsetY / 2;
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

  void attack() {
    if (!isAttacking && current != PlayerState.jump) {
      currentCombo = 1;
      startAttackAnimation(currentCombo);
    } else {
      if (queuedCombo < 2) {
        queuedCombo++;
      }
    }
  }
  void startAttackAnimation(int combo) {
    isAttacking = true;
    if (attackHitbox.isMounted) {
      attackHitbox.removeFromParent();
    }
    switch (combo) {
      case 1:
        current = PlayerState.attack1;
        break;
      case 2:
        current = PlayerState.attack2;
        break;
      case 3:
        current = PlayerState.attack3;
        break;
    }

    Future.delayed(Duration(milliseconds: 200), () {
      if (isAttacking) {
        attackHitbox.position = lastDirection == 1
            ? Vector2(20, 49)
            : Vector2(64, 49);
        attackHitbox.anchor =
        lastDirection == 1 ? Anchor.centerLeft : Anchor.centerRight;

        add(attackHitbox);
        Future.delayed(Duration(milliseconds: 200), () {
          if (attackHitbox.isMounted) {
            attackHitbox.removeFromParent();
          }
        });
      }
    });

    animationTicker?.onComplete = () {
      if (queuedCombo > 0 && currentCombo < 3) {
        queuedCombo--;
        currentCombo++;
        startAttackAnimation(currentCombo);
      } else {
        resetCombo();
      }
    };
  }

  void resetCombo() {
    isAttacking = false;
    currentCombo = 0;
    queuedCombo = 0;
    animationTicker?.onComplete = null;
  }
  void hurt(){
    if (gotHit) return;

    heartCount -= 1;

    isAttacking = false;
    currentCombo = 0;
    queuedCombo = 0;
    animationTicker?.onComplete = null;

    gotHit = true;
    invincibleTimer = invincibleDuration;

    if(heartCount > 0){
      current = PlayerState.hit;
    } else {
      respawn();
    }
  }


  void respawn() async {
    const canMoveDuration = Duration(milliseconds: 400);

    gotHit = true;
    isAttacking = false;
    horizontal = 0;
    velocity = Vector2.zero();
    lastDirection = 1;
    currentCombo = 0;
    queuedCombo = 0;
    heartCount = 3;

    current = PlayerState.death;
    await animationTicker?.completed;
    animationTicker?.reset();

    scale = Vector2.all(0.5);
    position = startingPosition - Vector2(0,32);
    current = PlayerState.idle;

    await Future.delayed(canMoveDuration);
    gotHit = false;
  }

  void _reachedCheckpoint() async {
    reachedCheckpoint = true;
    current = PlayerState.idle;
    isAttacking = false;
    horizontal = 0;
    velocity = Vector2.zero();
    await Future.delayed(const Duration(seconds: 2));
    await game.loadNextLevel();
    reachedCheckpoint = false;
  }
  void collidedWithEnemy() {
    hurt();
  }
}
