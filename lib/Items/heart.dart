import 'dart:async';

import 'package:final_project/Player/player.dart';
import 'package:final_project/knight.dart';
import 'package:final_project/Collisions/hitbox.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Heart extends SpriteAnimationComponent
    with HasGameReference<Knight>, CollisionCallbacks {
  final String heart;
  Heart({
    this.heart = 'Heart',
    super.position,
    super.size,
  }) : super(
  );
  Player? player;
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
      game.images.fromCache('Items/$heart.png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2.all(16),
      ),
    );

    scale = Vector2.all(1);

    return super.onLoad();
  }

  void collidedWithPlayer() async {
    if (!collected && game.player.heartCount < 3) {
      collected = true;
      game.player.heartCount += 1;
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
