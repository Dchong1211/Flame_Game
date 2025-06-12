import 'dart:async';
import 'package:final_project/Player/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:final_project/knight.dart';
import 'package:final_project/Collisions/collisions.dart';

class Bridge extends SpriteComponent with HasGameReference<Knight>, CollisionCallbacks {
  bool isPlayerOnBridge = false;
  double timer = 0;
  final double disappearTime = 1.5;
  bool isDisappearing = false;
  late final RectangleHitbox hitbox;
  final Vector2 startPosition;

  bool _isActive = true;

  Bridge({
    required Vector2 position,
    required Vector2 size,
  }) : startPosition = position.clone(),
        super(
        position: position,
        size: size,
      );

  @override
  FutureOr<void> onLoad() async {
    sprite = await game.loadSprite('Traps/Bridge.png');
    hitbox = RectangleHitbox()..collisionType = CollisionType.passive;
    add(hitbox);

    _addPlatformCollisionToPlayer();
    return super.onLoad();
  }

  void _removePlatformCollisionFromPlayer() {
    game.player.collisionBlocks.removeWhere((block) =>
    block.position == position && block.size == size && block.isPlatform);
  }

  void _addPlatformCollisionToPlayer() {
    game.player.collisionBlocks.removeWhere((block) =>
    block.position == position && block.size == size && block.isPlatform);
    game.player.collisionBlocks.add(
      CollisionBlock(
        position: position,
        size: size,
        isPlatform: true,
      ),
    );
  }

  void reset() {
    position = startPosition.clone();
    opacity = 1;
    isDisappearing = false;
    isPlayerOnBridge = false;
    timer = 0;
    _isActive = true;
    hitbox.collisionType = CollisionType.passive;

    _addPlatformCollisionToPlayer();

  }

  void disappear() {
    _removePlatformCollisionFromPlayer();

    if (isPlayerOnBridge && game.player.isOnGround) {
      game.player.isOnGround = false;
      game.player.velocity.y = 0;
    }

    opacity = 0;
    hitbox.collisionType = CollisionType.inactive;
    _isActive = false;
  }

  @override
  void update(double dt) {
    if (!_isActive) return;

    if (game.player.heartCount > 0) {
      if (isPlayerOnBridge && !isDisappearing) {
        timer += dt;
        if (timer >= disappearTime) {
          isDisappearing = true;
          disappear();
        }
      }
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_isActive) return;
    if (other is Player && game.player.heartCount > 0) {
      isPlayerOnBridge = true;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Player && game.player.heartCount > 0) {
      isPlayerOnBridge = false;
      if (_isActive) {
        timer = 0;
      }
    }
    super.onCollisionEnd(other);
  }

  @override
  void onMount() {
    super.onMount();
    game.player.respawnEvent.add(reset);
  }

  @override
  void onRemove() {
    _removePlatformCollisionFromPlayer();
    game.player.respawnEvent.remove(reset);
    super.onRemove();
  }
}