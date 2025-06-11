import 'package:final_project/Enemy/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class AttackHitbox extends PositionComponent with CollisionCallbacks {
  AttackHitbox({
    required super.size,
    required super.position,
  }) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Enemy) {
      other.takeDamage();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

