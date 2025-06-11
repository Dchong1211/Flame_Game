import 'dart:async';

import 'package:final_project/knight.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
class AttackButton extends SpriteComponent
    with HasGameReference<Knight>, TapCallbacks {
  AttackButton();
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('UI/AttackButton.png'));
    size = Vector2.all(96);
    anchor = Anchor.bottomRight;
    position = Vector2(game.size.x-70, game.size.y - 40);

    return super.onLoad();
  }
  @override
  void onTapDown(TapDownEvent event) {
    game.player.attack();
    super.onTapDown(event);
  }
}
