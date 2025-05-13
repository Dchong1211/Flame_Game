import 'dart:ui';

import '../player.dart';
import 'collisions.dart';

bool checkCollision(Player player, CollisionBlock block) {
  // Lấy hitbox vàng đã gán trong onLoad
  final hitbox = player.customHitbox;

  // Lấy Rect tuyệt đối của hitbox (vị trí thật trong thế giới game)
  final Rect playerRect = hitbox.toAbsoluteRect();

  // Tạo Rect của block (cũng là toạ độ tuyệt đối)
  final Rect blockRect = Rect.fromLTWH(
    block.x,
    block.y,
    block.width,
    block.height,
  );

  // So sánh va chạm 2 Rect
  return playerRect.overlaps(blockRect);
}
