import 'dart:async';
import 'dart:ui';
import 'package:final_project/Enemy/health_bar.dart';
import 'package:final_project/Player/attack_hitbox.dart';
import 'package:final_project/Player/player.dart';
import 'package:final_project/knight.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum State { idle, run, hit }

class Enemy extends SpriteAnimationGroupComponent
    with HasGameReference<Knight>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  double epsilon = 0.1;
  Enemy({
    super.position,
    super.size,
    this.offNeg = 0,
    this.offPos = 0,
  });

  static const stepTime = 0.05;
  static const tileSize = 16;
  static const runSpeed = 80;
  static const _bounceHeight = 260.0;

  final textureSize = Vector2(32, 34);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;

  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;

  bool isFacingLeft = true;
  int maxHealth = 3;
  int currentHealth = 3;
  late final HealthBar healthBar;
  double damageCooldown = 0;
  final double damageCooldownTime = 0.2; // 0.5 giây mới cho phép mất máu lần nữa


  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    anchor = Anchor.center;

    add(
      RectangleHitbox(
        position: Vector2(1, 2),
        size: Vector2(14, 14),
      ),
    );
    healthBar = HealthBar(
      maxHealth: maxHealth,
      currentHealth: currentHealth,
      size: Vector2(15, 2),
    )
      ..position = Vector2(size.x / 2 , -5)
      ..anchor = Anchor.topCenter;

    add(healthBar);

    _loadAllAnimations();
    _calculateRange();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (damageCooldown > 0) {
      damageCooldown -= dt;
    }

    _updateState();
    _movement(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is AttackHitbox && damageCooldown <= 0) {
      takeDamage();
    }
    super.onCollision(intersectionPoints, other);
  }



  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 13);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 15)..loop = false;

    animations = {
      State.idle: _idleAnimation,
      State.run: _runAnimation,
      State.hit: _hitAnimation,
    };

    current = State.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Chicken/$state (32x34).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }
  void _movement(double dt) {
    final player = game.player;
    double dx = player.center.x - center.x;
    const stopDistance = 20;

    if (playerInRange(player)) {
      if (dx.abs() > stopDistance) {
        targetDirection = dx.sign;
      } else {
        targetDirection = 0;
      }
    } else {
      targetDirection = 0;
    }

    moveDirection = lerpDouble(moveDirection, targetDirection, 0.15) ?? targetDirection;

    velocity.x = moveDirection * runSpeed;

    position.x += velocity.x * dt;

    position.x = position.x.clamp(rangeNeg, rangePos);
  }


  void _updateState() {
    current = (velocity.x.abs() > epsilon) ? State.run : State.idle;

    if (velocity.x < 0) {
      isFacingLeft = true;
    } else if (velocity.x > 0) {
      isFacingLeft = false;
    }

    scale.x = isFacingLeft ? 1 : -1;
  }

  Rect get detectionRect => Rect.fromLTRB(
    rangeNeg,
    position.y,
    rangePos,
    position.y + size.y,
  );

  bool playerInRange(Player player) {
    return detectionRect.overlaps(player.toRect());
  }
  void takeDamage() {
    if (damageCooldown > 0) return;
    current = State.hit;
    currentHealth -= 1;
    healthBar.updateHealth(currentHealth);

    if (currentHealth <= 0) {
      removeFromParent();
    }

    damageCooldown = damageCooldownTime;
  }

}
