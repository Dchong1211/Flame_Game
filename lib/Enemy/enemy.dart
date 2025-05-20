import 'dart:async';
import 'dart:ui';
import 'package:final_project/Enemy/enemy_attack_hitbox.dart';
import 'package:final_project/Enemy/health_bar.dart';
import 'package:final_project/Player/attack_hitbox.dart';
import 'package:final_project/Player/player.dart';
import 'package:final_project/knight.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum State { idle, run, hit, death, attack }

class Enemy extends SpriteAnimationGroupComponent<State>
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

  static const stepTime = 0.15;
  static const tileSize = 16;
  static const runSpeed = 50;

  final textureSize = Vector2(128, 128);

  Vector2 velocity = Vector2.zero();
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation deathAnimation;
  late final SpriteAnimation attackAnimation;

  bool isFacingLeft = true;
  int maxHealth = 3;
  int currentHealth = 3;
  late final HealthBar healthBar;

  bool isHit = false;
  bool isDead = false;
  double hitTimer = 0;
  final double hitDuration = 0.4;

  double damageCooldown = 0;
  final double damageCooldownTime = 0.2;

  bool isAttacking = false;
  double attackCooldown = 0;
  final double attackCooldownTime = 2.0;

  double attackAnimationTimer = 0.0;

  @override
  FutureOr<void> onLoad() {
    //debugMode = true;
    anchor = Anchor.center;

    add(
      RectangleHitbox(
        position: Vector2(11, 15),
        size: Vector2(10, 17),
      ),
    );

    healthBar = HealthBar(
      maxHealth: maxHealth,
      currentHealth: currentHealth,
      size: Vector2(15, 2),
    )
      ..position = Vector2(size.x / 2, 10)
      ..anchor = Anchor.topCenter;
    add(healthBar);

    loadAllAnimations();
    calculateRange();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (damageCooldown > 0) {
      damageCooldown -= dt;
    }

    if (isDead) {
      return;
    }

    if (isHit) {
      hitTimer -= dt;
      if (hitTimer <= 0) {
        isHit = false;
      }
    } else if (!isAttacking) {
      _updateState();
    }

    if (!isDead && !isHit && !isAttacking) {
      movement(dt);

      final player = game.player;
      if (playerInRange(player) && (player.center - center).length < 20) {
        attackPlayer();
      }
    }

    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }
    if (isAttacking) {
      attackAnimationTimer += dt;

      final totalAttackDuration = stepTime * attackAnimation.frames.length;

      if (attackAnimationTimer >= totalAttackDuration) {
        isAttacking = false;
        attackAnimationTimer = 0;
        current = State.idle;
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is AttackHitbox && damageCooldown <= 0) {
      takeDamage();
    }
    super.onCollision(intersectionPoints, other);
  }

  void loadAllAnimations() {
    idleAnimation = spriteAnimation('Idle', 4);
    runAnimation = spriteAnimation('Run', 6);
    attackAnimation = spriteAnimation('Attack', 5)..loop = false;
    hitAnimation = spriteAnimation('Hurt', 4)..loop = false;
    deathAnimation = spriteAnimation('Death', 5)..loop = false;

    animations = {
      State.idle: idleAnimation,
      State.run: runAnimation,
      State.hit: hitAnimation,
      State.death: deathAnimation,
      State.attack: attackAnimation,
    };

    current = State.idle;
  }

  SpriteAnimation spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Skeleton/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
  }

  void calculateRange() {
    rangeNeg = position.x - offNeg * tileSize;
    rangePos = position.x + offPos * tileSize;
  }

  void movement(double dt) {
    final player = game.player;
    double dx = player.center.x - center.x;
    const stopDistance = 15;

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
    if (damageCooldown > 0 || isDead) return;

    currentHealth -= 1;
    healthBar.updateHealth(currentHealth);

    if (currentHealth <= 0) {
      isDead = true;
      current = State.death;
      removeFromParent();
    } else {
      isHit = true;
      hitTimer = hitDuration;
      current = State.hit;
    }

    damageCooldown = damageCooldownTime;
  }

  void attackPlayer() {
    if (isAttacking || attackCooldown > 0) return;

    isAttacking = true;
    attackCooldown = attackCooldownTime;
    current = State.attack;
    attackAnimationTimer = 0;

    Future.delayed(const Duration(milliseconds: 300), () {
      final hitbox = EnemyAttackHitbox()
        ..position = Vector2(isFacingLeft ? 14 : 14, 22)
        ..anchor = Anchor.center;

      add(hitbox);

      Future.delayed(const Duration(milliseconds: 200), () {
        hitbox.removeFromParent();
      });
    });
  }

}
