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
    position = Vector2(900,350);

    return super.onLoad();
  }
  @override
  void onTapDown(TapDownEvent event) {
    game.player.attack();
    super.onTapDown(event);
  }
}
