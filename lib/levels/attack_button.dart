// import 'dart:async';
//
// import 'package:final_project/game2d.dart';
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
//
// class AttackButton extends SpriteComponent
//     with HasGameReference<Game2D>, TapCallbacks {
//   AttackButton();
//
//   final margin = 64;
//   final buttonSize = 64;
//
//   @override
//   FutureOr<void> onLoad() {
//     sprite = Sprite(game.images.fromCache('UI/AttackButton.png'));
//     position = Vector2(
//       game.size.x - margin - buttonSize,
//       game.size.y - margin - buttonSize,
//     );
//     return super.onLoad();
//   }
//
//   @override
//   void onTapDown(TapDownEvent event) {
//     game.player.attack(); // gọi hàm attack của player
//     super.onTapDown(event);
//   }
// }
