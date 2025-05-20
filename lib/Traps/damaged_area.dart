import 'dart:async';
import 'package:final_project/Player/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:final_project/knight.dart';

class DamagedArea extends PositionComponent
    with HasGameReference<Knight>, CollisionCallbacks {
  DamagedArea({
    super.position,
    super.size,
  });

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      collisionType: CollisionType.passive,
    ));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      if (!game.player.gotHit) {
        game.player.heartCount = 0;
        game.player.hurt();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}