import 'dart:ui';
import 'package:final_project/Player/player.dart';
import 'collisions.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final hitbox = player.customHitbox;
  final Rect playerRect = hitbox.toAbsoluteRect();
  final Rect blockRect = Rect.fromLTWH(
    block.x,
    block.y,
    block.width,
    block.height,
  );
  return playerRect.overlaps(blockRect);
}
