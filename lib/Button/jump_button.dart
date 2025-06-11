import 'dart:async';

import 'package:final_project/knight.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class JumpButton extends SpriteComponent
    with HasGameReference<Knight>, TapCallbacks {
  JumpButton();
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('UI/JumpButton.png'));
    size = Vector2.all(96);
    anchor = Anchor.bottomRight;
    position = Vector2(game.size.x-230, game.size.y - 40);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.jump();
    super.onTapDown(event);
  }
}