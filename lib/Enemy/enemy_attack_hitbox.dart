import 'package:final_project/Player/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class EnemyAttackHitbox extends PositionComponent with CollisionCallbacks {
  EnemyAttackHitbox() : super(size: Vector2(16, 20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    //debugMode = true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      other.hurt();
    }
    super.onCollision(intersectionPoints, other);
  }
}
