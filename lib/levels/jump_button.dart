import 'dart:async';

import 'package:final_project/game2D.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class JumpButton extends SpriteComponent
    with HasGameReference<Game2D>, TapCallbacks {
  JumpButton();

  final margin = 32;
  final buttonSize = 64;

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('UI/JumpButton.png'));
    position = Vector2(
      game.size.x - margin - buttonSize,
      game.size.y - margin - buttonSize,
    );
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Khi nút được nhấn, gọi phương thức jump() của player.
    // Logic double jump (kiểm tra jumpCount) nằm trong player.jump().
    game.player.jump();
    super.onTapDown(event);
  }

// onTapUp không cần thiết nữa vì chúng ta không sử dụng biến hasJumped để kích hoạt/dừng nhảy.
// @override
// void onTapUp(TapUpEvent event) {
//   game.player.hasJumped = false; // Xóa dòng này
//   super.onTapUp(event);
// }
}