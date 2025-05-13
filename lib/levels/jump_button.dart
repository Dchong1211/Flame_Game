import 'dart:async';

import 'package:final_project/game2d.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class JumpButton extends SpriteComponent
    with HasGameReference<Game2D>, TapCallbacks {
  JumpButton();
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('UI/JumpButton.png'));
    size = Vector2.all(96);
    position = Vector2(750,350);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.jump();
    super.onTapDown(event);
  }
}