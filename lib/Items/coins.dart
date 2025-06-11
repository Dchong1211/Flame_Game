import 'dart:async';
import 'package:final_project/knight.dart';
import 'package:final_project/Collisions/hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Coins extends SpriteAnimationComponent
    with HasGameReference<Knight>, CollisionCallbacks {
  final String coin;
  Coins({
    this.coin = 'Coins',
    super.position,
    super.size,
  }) : super(
  );

  final double stepTime = 0.05;
  final hitbox = PlayerHitbox(
    offsetX: 0,
    offsetY: 0,
    width: 8,
    height: 8,
  );
  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    //debugMode = true;
    add(
      RectangleHitbox(
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/$coin.png'),
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: stepTime,
        textureSize: Vector2.all(16),
      ),
    );

    scale = Vector2.all(1);

    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true;
      game.coinCount += 1;

      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/MonedaP.png'),
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: stepTime,
          textureSize: Vector2.all(16),
          loop: false,
        ),
      );

      await animationTicker?.completed;
      removeFromParent();
    }
  }

}
